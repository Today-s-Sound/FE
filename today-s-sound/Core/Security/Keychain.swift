//
//  Keychain.swift
//  today-s-sound
//
//  Created by 하승연 on 10/30/25.
//

import Foundation
import Security

enum KeychainKey {
  static let deviceSecret = "device_secret"
  static let userId = "user_id"
  static let apiKey = "api_key" // 서버가 추가 키를 준다면 여기에 저장 (옵셔널)

  // NOTE: FCM 토큰은 Keychain에 저장하지 않음
  // - Firebase SDK가 자체적으로 토큰을 관리/캐싱함
  // - Messaging.messaging().fcmToken으로 언제든 현재 토큰 조회 가능
  // - 토큰 갱신 시 didReceiveRegistrationToken 콜백에서 서버에 업데이트
}

enum Keychain {
  @discardableResult
  static func set(_ value: Data, for key: String) -> Bool {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key,
      kSecValueData as String: value,
      kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock // 앱 재부팅 후에도 접근
    ]
    SecItemDelete(query as CFDictionary) // 기존 값 제거
    let status = SecItemAdd(query as CFDictionary, nil)
    return status == errSecSuccess
  }

  static func get(for key: String) -> Data? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne
    ]
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    guard status == errSecSuccess else { return nil }
    return (item as? Data)
  }

  @discardableResult
  static func delete(for key: String) -> Bool {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key
    ]
    let status = SecItemDelete(query as CFDictionary)
    return status == errSecSuccess || status == errSecItemNotFound
  }

  // 문자열 편의 메서드
  @discardableResult
  static func setString(_ value: String, for key: String) -> Bool {
    set(Data(value.utf8), for: key)
  }

  static func getString(for key: String) -> String? {
    guard let data = get(for: key) else { return nil }
    return String(data: data, encoding: .utf8)
  }
}
