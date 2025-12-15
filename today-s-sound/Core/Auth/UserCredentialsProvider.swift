//
//  UserCredentialsProvider.swift
//  today-s-sound
//
//  Created for code review improvements
//

import Foundation

/// 사용자 인증 정보를 제공하는 프로토콜
/// 테스트 가능성을 높이기 위해 추상화
protocol UserCredentialsProvider {
  /// 사용자 ID를 반환
  func getUserId() -> String?
  
  /// 디바이스 시크릿을 반환
  func getDeviceSecret() -> String?
  
  /// 사용자 ID와 디바이스 시크릿을 튜플로 반환
  /// 둘 다 존재할 때만 반환, 없으면 nil
  func getCredentials() -> (userId: String, deviceSecret: String)?
}

/// Keychain을 사용하는 UserCredentialsProvider 구현체
final class KeychainCredentialsProvider: UserCredentialsProvider {
  func getUserId() -> String? {
    Keychain.getString(for: KeychainKey.userId)
  }
  
  func getDeviceSecret() -> String? {
    Keychain.getString(for: KeychainKey.deviceSecret)
  }
  
  func getCredentials() -> (userId: String, deviceSecret: String)? {
    guard let userId = Keychain.getString(for: KeychainKey.userId),
          let deviceSecret = Keychain.getString(for: KeychainKey.deviceSecret)
    else {
      return nil
    }
    return (userId, deviceSecret)
  }
}

#if DEBUG
  /// 테스트용 Mock 구현체
  final class MockCredentialsProvider: UserCredentialsProvider {
    var userId: String?
    var deviceSecret: String?
    
    init(userId: String? = "test-user-id", deviceSecret: String? = "test-device-secret") {
      self.userId = userId
      self.deviceSecret = deviceSecret
    }
    
    func getUserId() -> String? {
      userId
    }
    
    func getDeviceSecret() -> String? {
      deviceSecret
    }
    
    func getCredentials() -> (userId: String, deviceSecret: String)? {
      guard let userId = userId, let deviceSecret = deviceSecret else {
        return nil
      }
      return (userId, deviceSecret)
    }
  }
#endif
