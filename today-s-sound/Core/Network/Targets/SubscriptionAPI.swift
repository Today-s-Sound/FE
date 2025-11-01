//
//  SubscriptionAPI.swift
//  today-s-sound
//
//  Created by Assistant
//

import Foundation
import Moya

enum SubscriptionAPI {
  case getSubscriptions(userId: String, deviceSecret: String, page: Int, size: Int)
}

extension SubscriptionAPI: APITargetType {
  var path: String {
    switch self {
    case .getSubscriptions:
      "/api/subscriptions"
    }
  }

  var method: Moya.Method {
    switch self {
    case .getSubscriptions:
      .get
    }
  }

  var task: Task {
    switch self {
    case let .getSubscriptions(_, _, page, size):
      .requestParameters(
        parameters: [
          "page": page,
          "size": size
        ],
        encoding: URLEncoding.queryString
      )
    }
  }

  var headers: [String: String]? {
    switch self {
    case let .getSubscriptions(userId, deviceSecret, _, _):
      [
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-User-ID": userId,
        "X-Device-Secret": deviceSecret
      ]
    }
  }
}
