//
//  User.swift
//  today-s-sound
//
//  Refactored by Assistant
//

import Foundation

// MARK: - 익명 사용자 등록

struct RegisterAnonymousRequest: Codable {
  let deviceSecret: String
  let model: String?
  let fcmToken: String?
}

struct AnonymousUserResult: Codable {
  let userId: String
}

/// 익명 사용자 등록 응답
typealias RegisterAnonymousResponse = APIResponse<AnonymousUserResult>

// MARK: - 에러 응답

struct APIErrorResponse: Codable, Error {
  let status: Int
  let code: String
  let message: String
}

// MARK: - Device Secret 생성 유틸

enum DeviceSecretGenerator {
  static func generate() -> String {
    var bytes = [UInt8](repeating: 0, count: 32)
    _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
    // URL-safe base64
    let data = Data(bytes)
    return data.base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
  }
}
