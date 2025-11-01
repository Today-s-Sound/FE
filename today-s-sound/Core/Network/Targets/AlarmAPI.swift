//
//  AlarmAPI.swift
//  today-s-sound
//
//  Created by Assistant
//

import Foundation
import Moya

enum AlarmAPI {
  case getAlarms(userId: String, deviceSecret: String, page: Int, size: Int)
}

extension AlarmAPI: APITargetType {
  var path: String {
    switch self {
    case .getAlarms:
      "/api/alarms"
    }
  }

  var method: Moya.Method {
    switch self {
    case .getAlarms:
      .get
    }
  }

  var task: Task {
    switch self {
    case let .getAlarms(_, _, page, size):
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
    case let .getAlarms(userId, deviceSecret, _, _):
      [
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-User-ID": userId,
        "X-Device-Secret": deviceSecret
      ]
    }
  }
}
