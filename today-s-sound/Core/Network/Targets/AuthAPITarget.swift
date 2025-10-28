import Foundation
import Moya

enum AuthAPITarget {
  case refresh(refreshToken: String)
}

extension AuthAPITarget: APITargetType {
  var path: String {
    switch self {
    case .refresh:
      "/api/auth/refresh"
    }
  }

  var method: Moya.Method { .post }

  var task: Task {
    switch self {
    case let .refresh(refreshToken: refreshToken):
      .requestParameters(parameters: ["refreshToken": refreshToken], encoding: JSONEncoding.default)
    }
  }

  var headers: [String: String]? { ["Content-Type": "application/json"] }
}

struct RefreshResponseDTO: Codable {
  let isSuccess: Bool
  let data: RefreshTokensDTO?
}

struct RefreshTokensDTO: Codable {
  let accessToken: String
  let refreshToken: String
}
