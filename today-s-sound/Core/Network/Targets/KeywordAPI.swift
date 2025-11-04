//
//  KeywordAPI.swift
//  today-s-sound
//
//  Created by Assistant
//

import Foundation
import Moya

enum KeywordAPI {
  case getKeywords
}

extension KeywordAPI: APITargetType {
  var path: String {
    switch self {
    case .getKeywords:
      "/api/subscriptions/keywords"
    }
  }

  var method: Moya.Method {
    switch self {
    case .getKeywords:
      .get
    }
  }

  var task: Task {
    switch self {
    case .getKeywords:
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

