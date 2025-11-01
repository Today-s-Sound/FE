import Combine
import CombineMoya
import Foundation
import Moya

protocol APIServiceType {
  func request<T: Decodable>(_ target: some TargetType) -> AnyPublisher<T, NetworkError>
  func registerAnonymous(deviceSecret: String) -> AnyPublisher<RegisterAnonymousResponse, NetworkError>
  func getSubscriptions(userId: String, deviceSecret: String, page: Int, size: Int) -> AnyPublisher<SubscriptionListResponse, NetworkError>
}

class APIService: APIServiceType {
  private let userProvider: MoyaProvider<UserAPI>
  private let authProvider: MoyaProvider<AuthAPITarget>
  private let subscriptionProvider: MoyaProvider<SubscriptionAPI>

  init(userSession: UserSession = UserSession()) {
    #if DEBUG
    // 개발 모드에서는 로깅 플러그인 추가
    let logger = NetworkLoggerPlugin(configuration: .init(
      logOptions: .verbose
    ))
    userProvider = NetworkKit.provider(userSession: userSession, plugins: [logger])
    authProvider = NetworkKit.provider(userSession: userSession, plugins: [logger])
    subscriptionProvider = NetworkKit.provider(userSession: userSession, plugins: [logger])
    #else
    userProvider = NetworkKit.provider(userSession: userSession)
    authProvider = NetworkKit.provider(userSession: userSession)
    subscriptionProvider = NetworkKit.provider(userSession: userSession)
    #endif
  }

  // MARK: - Generic Request
  
  func request<T: Decodable>(_ target: some TargetType) -> AnyPublisher<T, NetworkError> {
    Fail<T, NetworkError>(error: .requestFailed(NSError(domain: "NotImplemented", code: -1)))
      .eraseToAnyPublisher()
  }

  // MARK: - User API
  
  func registerAnonymous(deviceSecret: String) -> AnyPublisher<RegisterAnonymousResponse, NetworkError> {
    userProvider.requestPublisher(.registerAnonymous(deviceSecret: deviceSecret))
      .tryMap { response -> Data in
        // 상태 코드 체크
        guard (200 ... 299).contains(response.statusCode) else {
          throw NetworkError.serverError(statusCode: response.statusCode)
        }
        
        // 🐛 디버깅: 서버 응답 출력
        #if DEBUG
        if let jsonString = String(data: response.data, encoding: .utf8) {
          print("📥 서버 응답 (Raw JSON):")
          print(jsonString)
        }
        #endif
        
        return response.data
      }
      .decode(type: RegisterAnonymousResponse.self, decoder: JSONDecoder()) // JSON 데이터를 RegisterAnonymousResponse 구조체로 자동 변환
      .mapError { error -> NetworkError in
        // 🐛 디버깅: 디코딩 에러 상세 출력
        #if DEBUG
        if let decodingError = error as? DecodingError {
          print("❌ 디코딩 에러 발생:")
          switch decodingError {
          case .keyNotFound(let key, let context):
            print("  - 키를 찾을 수 없음: \(key.stringValue)")
            print("  - 경로: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
            print("  - 설명: \(context.debugDescription)")
          case .typeMismatch(let type, let context):
            print("  - 타입 불일치: \(type)")
            print("  - 경로: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
          case .valueNotFound(let type, let context):
            print("  - 값을 찾을 수 없음: \(type)")
            print("  - 경로: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
          case .dataCorrupted(let context):
            print("  - 데이터 손상")
            print("  - 경로: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
          @unknown default:
            print("  - 알 수 없는 디코딩 에러")
          }
        }
        #endif
        
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
  
  // MARK: - Subscription API
  
  func getSubscriptions(userId: String, deviceSecret: String, page: Int = 0, size: Int = 10) -> AnyPublisher<SubscriptionListResponse, NetworkError> {
    subscriptionProvider.requestPublisher(.getSubscriptions(
      userId: userId,
      deviceSecret: deviceSecret,
      page: page,
      size: size
    ))
    .tryMap { response -> Data in
      // 상태 코드 체크
      guard (200...299).contains(response.statusCode) else {
        throw NetworkError.serverError(statusCode: response.statusCode)
      }
      
      // 🐛 디버깅: 서버 응답 출력
      #if DEBUG
      if let jsonString = String(data: response.data, encoding: .utf8) {
        print("📥 구독 목록 응답 (Raw JSON):")
        print(jsonString)
      }
      #endif
      
      return response.data
    }
    .decode(type: SubscriptionListResponse.self, decoder: JSONDecoder())
    .mapError { error -> NetworkError in
      // 🐛 디버깅: 디코딩 에러 상세 출력
      #if DEBUG
      if let decodingError = error as? DecodingError {
        print("❌ 디코딩 에러 발생:")
        switch decodingError {
        case .keyNotFound(let key, let context):
          print("  - 키를 찾을 수 없음: \(key.stringValue)")
          print("  - 경로: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
        case .typeMismatch(let type, let context):
          print("  - 타입 불일치: \(type)")
          print("  - 경로: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
        case .valueNotFound(let type, let context):
          print("  - 값을 찾을 수 없음: \(type)")
        case .dataCorrupted(let context):
          print("  - 데이터 손상")
        @unknown default:
          print("  - 알 수 없는 디코딩 에러")
        }
      }
      #endif
      
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
