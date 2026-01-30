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

// MARK: - FCM 토큰 업데이트 (v2)

/// FCM 토큰 업데이트 요청 (v2)
/// - fcmToken: Firebase Cloud Messaging 토큰
/// - model: 디바이스 모델 식별자 (예: "iPhone15,2", "iPad14,1")
struct UpdateFCMTokenRequest: Codable {
  let fcmToken: String
  let model: String
}

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
