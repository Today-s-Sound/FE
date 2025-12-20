//
//  UserAPI.swift
//  today-s-sound
//
//  Refactored by Assistant
//

import Foundation
import Moya

enum UserAPI {
  case registerAnonymous(request: RegisterAnonymousRequest)
  case withdraw(deviceSecret: String)
}

extension UserAPI: APITargetType {
  var path: String {
    switch self {
    case .registerAnonymous:
      "/api/users/anonymous"
    case let .withdraw(deviceSecret):
      "/api/users/withdraw/\(deviceSecret)"
    }
  }

  var method: Moya.Method {
    switch self {
    case .registerAnonymous:
      .post
    case .withdraw:
      .delete
    }
  }

  var task: Task {
    switch self {
    case let .registerAnonymous(request):
      .requestJSONEncodable(request)
    case .withdraw:
      .requestPlain
    }
  }

  var headers: [String: String]? {
    [
      "Content-Type": "application/json",
      "Accept": "application/json"
    ]
  }
}
