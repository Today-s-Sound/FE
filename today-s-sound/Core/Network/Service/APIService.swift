import Combine
import CombineMoya
import Foundation
import Moya

protocol APIServiceType {
  func request<T: Decodable, Target: TargetType>(_ target: Target) -> AnyPublisher<T, NetworkError>
  func createAnonymous(deviceSecret: String) -> AnyPublisher<AnonymousUserResponse, NetworkError>
}

class APIService: APIServiceType {
  private let anonymousProvider: MoyaProvider<AnonymousAPI>

  init(userSession: UserSession = UserSession()) {
    self.anonymousProvider = NetworkKit.provider(userSession: userSession)
  }

  func request<T: Decodable, Target: TargetType>(_ target: Target) -> AnyPublisher<T, NetworkError> {
    Fail<T, NetworkError>(error: .requestFailed(NSError(domain: "NotImplemented", code: -1))).eraseToAnyPublisher()
  }

  func createAnonymous(deviceSecret: String) -> AnyPublisher<AnonymousUserResponse, NetworkError> {
    anonymousProvider.requestPublisher(.createAnonymous(deviceSecret: deviceSecret))
      .tryMap { response -> Data in
        guard (200 ... 299).contains(response.statusCode) else {
          throw NetworkError.serverError(statusCode: response.statusCode)
        }
        return response.data
      }
      .decode(type: AnonymousUserResponse.self, decoder: JSONDecoder())
      .mapError { error -> NetworkError in
        if let networkError = error as? NetworkError {
          return networkError
        } else if error is DecodingError {
          return .decodingFailed(error)
        } else {
          return .requestFailed(error)
        }
      }
      .eraseToAnyPublisher()
  }
}


