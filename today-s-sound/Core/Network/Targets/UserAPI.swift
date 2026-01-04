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
  case withdraw(userId: String, deviceSecret: String)
  case updateFCMToken(userId: String, deviceSecret: String, request: UpdateFCMTokenRequest)
}

extension UserAPI: APITargetType {
  var path: String {
    switch self {
    case .registerAnonymous:
      "/api/users/anonymous"
    case .withdraw:
      "/api/users/withdraw"
    case .updateFCMToken:
      "/api/fcm"
    }
  }

  var method: Moya.Method {
    switch self {
    case .registerAnonymous:
      .post
    case .withdraw:
      .delete
    case .updateFCMToken:
      .put
    }
  }

  var task: Task {
    switch self {
    case let .registerAnonymous(request):
      .requestJSONEncodable(request)
    case .withdraw:
      .requestPlain
    case let .updateFCMToken(_, _, request):
      .requestJSONEncodable(request)
    }
  }

  var headers: [String: String]? {
    switch self {
    case .registerAnonymous:
      [
        "Content-Type": "application/json",
        "Accept": "application/json"
      ]
    case let .withdraw(userId, deviceSecret):
      [
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-User-ID": userId,
        "X-Device-Secret": deviceSecret
      ]
    case let .updateFCMToken(userId, deviceSecret, _):
      [
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-User-ID": userId,
        "X-Device-Secret": deviceSecret
      ]
    }
  }
}
