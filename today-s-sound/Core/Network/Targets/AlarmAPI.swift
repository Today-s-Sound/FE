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
  case markAsRead(userId: String, deviceSecret: String, summaryIds: [Int64])
  case deleteSummary(userId: String, deviceSecret: String, summaryId: Int64)
}

extension AlarmAPI: APITargetType {
  var path: String {
    switch self {
    case .getAlarms:
      "/api/alarms"
    case .markAsRead:
      "/api/alarms/summaries/read"
    case let .deleteSummary(_, _, summaryId):
      "/api/summaries/\(summaryId)"
    }
  }

  var method: Moya.Method {
    switch self {
    case .getAlarms:
      .get
    case .markAsRead:
      .patch
    case .deleteSummary:
      .delete
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
    case let .markAsRead(_, _, summaryIds):
      .requestJSONEncodable(MarkAlarmsReadRequest(summaryIds: summaryIds))
    case .deleteSummary:
      .requestPlain
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
    case let .markAsRead(userId, deviceSecret, _):
      [
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-User-ID": userId,
        "X-Device-Secret": deviceSecret
      ]
    case let .deleteSummary(userId, deviceSecret, _):
      [
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-User-ID": userId,
        "X-Device-Secret": deviceSecret
      ]
    }
  }
}
