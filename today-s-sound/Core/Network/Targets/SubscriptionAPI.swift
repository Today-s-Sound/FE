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
  case createSubscription(userId: String, deviceSecret: String, request: CreateSubscriptionRequest)
  case deleteSubscription(userId: String, deviceSecret: String, subscriptionId: Int64)
}

extension SubscriptionAPI: APITargetType {
  var path: String {
    switch self {
    case .getSubscriptions:
      "/api/subscriptions"
    case .createSubscription:
      "/api/subscriptions"
    case let .deleteSubscription(_, _, subscriptionId):
      "/api/subscriptions/\(subscriptionId)"
    }
  }

  var method: Moya.Method {
    switch self {
    case .getSubscriptions:
      .get
    case .createSubscription:
      .post
    case .deleteSubscription:
      .delete
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
    case let .createSubscription(_, _, request):
      .requestJSONEncodable(request)
    case .deleteSubscription:
      .requestPlain
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
    case let .createSubscription(userId, deviceSecret, _):
      [
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-User-ID": userId,
        "X-Device-Secret": deviceSecret
      ]
    case let .deleteSubscription(userId, deviceSecret, _):
      [
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-User-ID": userId,
        "X-Device-Secret": deviceSecret
      ]
    }
  }
}
