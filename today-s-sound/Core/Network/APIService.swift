
import Foundation
import Combine
import Moya
import CombineMoya

// Example TargetType - replace with actual API endpoints
enum TodaySoundAPI {
    case fetchContent(id: String)
}

extension TodaySoundAPI: TargetType {
    var baseURL: URL { URL(string: "https://your-api-url.com")! }

    var path: String {
        switch self {
        case .fetchContent(let id):
            return "/content/\(id)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .fetchContent:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .fetchContent:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}

protocol APIServiceType {
    func request<T: Decodable>(_ target: TodaySoundAPI) -> AnyPublisher<T, NetworkError>
}

class APIService: APIServiceType {
    private let provider: MoyaProvider<TodaySoundAPI>

    init(provider: MoyaProvider<TodaySoundAPI> = MoyaProvider<TodaySoundAPI>()) {
        self.provider = provider
    }

    func request<T: Decodable>(_ target: TodaySoundAPI) -> AnyPublisher<T, NetworkError> {
        return provider.requestPublisher(target)
            .tryMap { response -> Data in
                guard (200...299).contains(response.statusCode) else {
                    throw NetworkError.serverError(statusCode: response.statusCode)
                }
                return response.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
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
