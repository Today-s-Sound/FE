//
//  FeedAPI.swift
//  today-s-sound
//
//  Created by Assistant
//

import Foundation
import Moya

enum FeedAPI {
  case getHomeFeed(userId: String, deviceSecret: String)
  case getFeeds(userId: String, deviceSecret: String, page: Int, size: Int)
}

extension FeedAPI: APITargetType {
  var path: String {
    switch self {
    case .getHomeFeed:
      "/api/feeds/home"
    case .getFeeds:
      "/api/feeds"
    }
  }

  var method: Moya.Method {
    switch self {
    case .getHomeFeed, .getFeeds:
      .get
    }
  }

  var task: Task {
    switch self {
    case .getHomeFeed:
      .requestPlain
    case let .getFeeds(_, _, page, size):
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
    case let .getHomeFeed(userId, deviceSecret):
      [
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-User-ID": userId,
        "X-Device-Secret": deviceSecret
      ]
    case let .getFeeds(userId, deviceSecret, _, _):
      [
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-User-ID": userId,
        "X-Device-Secret": deviceSecret
      ]
    }
  }
}
