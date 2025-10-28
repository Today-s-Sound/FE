import Foundation
import Moya

enum AnonymousAPI {
  case createAnonymous(deviceSecret: String)
}

extension AnonymousAPI: APITargetType {
  var path: String {
    switch self {
    case .createAnonymous:
      "/api/users/anonymous"
    }
  }

  var method: Moya.Method { .post }

  var task: Task {
    switch self {
    case let .createAnonymous(deviceSecret):
      .requestParameters(parameters: ["deviceSecret": deviceSecret], encoding: JSONEncoding.default)
    }
  }

  var headers: [String: String]? { ["Content-Type": "application/json"] }
}
