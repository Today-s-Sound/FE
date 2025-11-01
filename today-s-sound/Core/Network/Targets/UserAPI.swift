//
//  UserAPI.swift
//  today-s-sound
//
//  Refactored by Assistant
//

import Foundation
import Moya

enum UserAPI {
  case registerAnonymous(deviceSecret: String)
  // 향후 추가 가능:
  // case getUserProfile(userId: String)
  // case updateProfile(userId: String, name: String)
}

extension UserAPI: APITargetType {
  var path: String {
    switch self {
    case .registerAnonymous:
      "/api/users/anonymous"
    }
  }

  var method: Moya.Method {
    switch self {
    case .registerAnonymous:
      .post
    }
  }

  var task: Task {
    switch self {
    case let .registerAnonymous(deviceSecret):
      .requestParameters(
        parameters: ["deviceSecret": deviceSecret],
        encoding: JSONEncoding.default
      )
    }
  }

  var headers: [String: String]? {
    [
      "Content-Type": "application/json",
      "Accept": "application/json"
    ]
  }
}
