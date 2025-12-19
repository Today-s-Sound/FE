//
//  URLAPI.swift
//  today-s-sound
//
//  Created by Assistant
//

import Foundation
import Moya

enum URLAPI {
  case getURLs
}

extension URLAPI: APITargetType {
  var path: String {
    switch self {
    case .getURLs:
      "/api/urls"
    }
  }

  var method: Moya.Method {
    switch self {
    case .getURLs:
      .get
    }
  }

  var task: Task {
    switch self {
    case .getURLs:
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
