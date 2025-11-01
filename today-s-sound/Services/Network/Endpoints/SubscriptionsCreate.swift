//
//  SubscriptionsCreate.swift
//  today-s-sound
//
//  Created by 하승연 on 10/31/25.
//

import Foundation

// 요청 바디
struct CreateSubscriptionBody: Encodable {
  let url: String
}

// 응답
struct CreateSubscriptionResp: Decodable {
  let subscriptionId: Int
}

// 헤더 빌더(키체인에서 읽어서 만드는 편의 함수)
enum AuthHeaders {
  static func userAndDevice() throws -> [String: String] {
    guard let uid = Keychain.getString(for: KeychainKey.userId),
          let secret = Keychain.getString(for: KeychainKey.deviceSecret)
    else {
      throw APIError.underlying(NSError(domain: "AuthHeaders", code: -1, userInfo: [NSLocalizedDescriptionKey: "등록 정보가 없습니다"]))
    }
    return [
      "X-User-ID": uid,
      "X-Device-Secret": secret
    ]
  }
}
