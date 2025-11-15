//
//  SessionStore.swift
//  today-s-sound
//
//  Refactored by Assistant - Moya 기반으로 리팩토링
//

import Combine
import FirebaseMessaging
import Foundation
import SwiftUI
import UIKit

@MainActor
final class SessionStore: ObservableObject {
  @Published private(set) var userId: String?
  @Published private(set) var isRegistered: Bool = false
  @Published var lastError: String?

  private let apiService: APIService
  private var cancellables = Set<AnyCancellable>()

  init(apiService: APIService = APIService()) {
    self.apiService = apiService

    // 앱 시작 시, 키체인에 저장되어 있으면 로드
    #if DEBUG
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━")
      print("🔐 키체인 확인 (SessionStore.init)")
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━")
      if let deviceSecret = Keychain.getString(for: KeychainKey.deviceSecret) {
        print("✅ deviceSecret: \(deviceSecret)")
      } else {
        print("❌ deviceSecret: (없음)")
      }
      if let savedId = Keychain.getString(for: KeychainKey.userId) {
        print("✅ userId: \(savedId)")
      } else {
        print("❌ userId: (없음)")
      }
      if let fcmToken = Keychain.getString(for: KeychainKey.fcmToken) {
        print("✅ fcmToken: \(fcmToken)")
      } else {
        print("❌ fcmToken: (없음)")
      }
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    #else
      print("⚠️ RELEASE 모드로 실행 중 - DEBUG 로그 비활성화")
    #endif

    // deviceSecret, userId, fcmToken 모두 있어야 등록된 것으로 간주
    let hasDeviceSecret = Keychain.getString(for: KeychainKey.deviceSecret) != nil
    let hasUserId = Keychain.getString(for: KeychainKey.userId) != nil
    let hasFcmToken = Keychain.getString(for: KeychainKey.fcmToken) != nil

    if hasDeviceSecret, hasUserId, hasFcmToken {
      userId = Keychain.getString(for: KeychainKey.userId)
      isRegistered = true
    } else {
      isRegistered = false
    }
  }

  /// 처음 실행 시 한 번 호출: deviceSecret 생성/보관 → 서버 등록
  func registerIfNeeded() async {
    guard !isRegistered else { return }

    // 1) deviceSecret을 키체인에서 찾고, 없으면 생성하여 저장
    let secret: String = {
      if let savedSecret = Keychain.getString(for: KeychainKey.deviceSecret) {
        return savedSecret
      }
      let generated = DeviceSecretGenerator.generate()
      Keychain.setString(generated, for: KeychainKey.deviceSecret)
      return generated
    }()

    // 2) 디바이스 모델 정보 가져오기
    let deviceModel = UIDevice.current.model

    // 3) FCM 토큰 가져오기
    let fcmToken = Messaging.messaging().fcmToken

    // 4) FCM 토큰이 있으면 키체인에 저장
    if let fcmToken {
      Keychain.setString(fcmToken, for: KeychainKey.fcmToken)
    }

    // 5) 요청 객체 생성
    let request = RegisterAnonymousRequest(
      deviceSecret: secret,
      model: deviceModel,
      fcmToken: fcmToken
    )

    // 6) Combine을 사용한 비동기 API 호출
    await withCheckedContinuation { continuation in
      apiService.registerAnonymous(request: request)
        .sink(
          receiveCompletion: { [weak self] completion in
            guard let self else { return }

            switch completion {
            case .finished:
              break

            case let .failure(error):
              // 에러 처리
              switch error {
              case let .serverError(statusCode):
                lastError = "서버 오류 (상태: \(statusCode))"

              case let .decodingFailed(decodeError):
                lastError = "응답 처리 실패: \(decodeError.localizedDescription)"

              case let .requestFailed(requestError):
                lastError = "요청 실패: \(requestError.localizedDescription)"

              case .invalidURL:
                lastError = "잘못된 URL"

              case .unknown:
                lastError = "알 수 없는 오류"
              }

              print("❌ 익명 사용자 등록 실패: \(lastError ?? "")")
            }

            continuation.resume()
          },
          receiveValue: { [weak self] response in
            guard let self else { return }

            // 6) userId 저장
            let userId = response.result.userId
            Keychain.setString(userId, for: KeychainKey.userId)

            self.userId = userId
            isRegistered = true
            lastError = nil

            print("✅ 익명 사용자 등록 성공: \(userId)")
          }
        )
        .store(in: &self.cancellables)
    }
  }

  /// 로그아웃 (키체인 초기화)
  func logout() {
    Keychain.delete(for: KeychainKey.userId)
    Keychain.delete(for: KeychainKey.deviceSecret)
    Keychain.delete(for: KeychainKey.fcmToken)

    userId = nil
    isRegistered = false
    lastError = nil
  }
}
