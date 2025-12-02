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
  case deleteSubscription(userId: String, deviceSecret: String, subscriptionId: Int64)
  case blockAlarm(userId: String, deviceSecret: String, subscriptionId: Int64)
  case unblockAlarm(userId: String, deviceSecret: String, subscriptionId: Int64)
}

extension SubscriptionAPI: APITargetType {
  var path: String {
    switch self {
    case .getSubscriptions:
      "/api/subscriptions"
    case let .deleteSubscription(_, _, subscriptionId):
      "/api/subscriptions/\(subscriptionId)"
    case let .blockAlarm(_, _, subscriptionId):
      "/api/subscriptions/\(subscriptionId)/alarm/block"
    case let .unblockAlarm(_, _, subscriptionId):
      "/api/subscriptions/\(subscriptionId)/alarm/unblock"
    }
  }

  var method: Moya.Method {
    switch self {
    case .getSubscriptions:
      .get
    case .deleteSubscription:
      .delete
    case .blockAlarm, .unblockAlarm:
      .patch
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
    case .deleteSubscription, .blockAlarm, .unblockAlarm:
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
    case let .deleteSubscription(userId, deviceSecret, _):
      [
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-User-ID": userId,
        "X-Device-Secret": deviceSecret
      ]
    case let .blockAlarm(userId, deviceSecret, _):
      [
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-User-ID": userId,
        "X-Device-Secret": deviceSecret
      ]
    case let .unblockAlarm(userId, deviceSecret, _):
      [
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-User-ID": userId,
        "X-Device-Secret": deviceSecret
      ]
    }
  }
}
