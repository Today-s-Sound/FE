//
//  TodaySSoundApp.swift
//  today-s-sound
//
//  Created by 하승연 on 9/28/25.
//

import Combine
import FirebaseCore
import FirebaseMessaging
import SwiftUI
import UIKit
import UserNotifications

// MARK: - UIDevice Extension (상세 모델 식별자)

extension UIDevice {
  /// 디바이스 모델 식별자 반환 (예: "iPhone15,2", "iPad14,1")
  /// - UIDevice.current.model은 "iPhone", "iPad" 같은 일반적인 값만 반환
  /// - 이 프로퍼티는 실제 하드웨어 식별자를 반환
  var modelIdentifier: String {
    #if targetEnvironment(simulator)
      // 시뮬레이터에서는 환경변수에서 가져옴
      return ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "Simulator"
    #else
      var systemInfo = utsname()
      uname(&systemInfo)
      let machineMirror = Mirror(reflecting: systemInfo.machine)
      let identifier = machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
      }
      return identifier
    #endif
  }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate { // 3. Delegate 프로토콜 3개 추가

  // APNs 등록 상태 추적
  private var hasRegisteredForRemoteNotifications = false

  // FCM 토큰 업데이트를 위한 API 서비스
  private let apiService = APIService()
  private var cancellables = Set<AnyCancellable>()

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
  {
    FirebaseApp.configure()

    UNUserNotificationCenter.current().delegate = self

    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(
      options: authOptions,
      completionHandler: { granted, _ in
        print("알림 권한 허용: \(granted)")
      }
    )

    // 6. APNs에 기기 등록 요청
    // NOTE: APNs 등록은 앱 시작 시 항상 실행
    // - FCM 토큰이 있어도 APNs 토큰은 갱신될 수 있음
    // - Firebase SDK가 APNs ↔ FCM 토큰 매핑을 자동 처리
    // - 토큰 갱신 시 didReceiveRegistrationToken 콜백 호출됨
    if !hasRegisteredForRemoteNotifications {
      print("📱 [APNs] 기기 등록 요청")
      application.registerForRemoteNotifications()
    }

    // 7. FCM 메시징 대리자 설정
    Messaging.messaging().delegate = self

    return true
  }

  // 8. FCM 토큰을 수신했을 때 호출되는 함수
  // NOTE: 이 콜백은 다음 상황에서 호출됨
  // - 앱 최초 실행 시 토큰 발급
  // - Firebase SDK가 토큰을 갱신할 때 (보안상 주기적 갱신)
  // - 앱 삭제 후 재설치 시
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("====================================")
    print("🔔 [FCM] 토큰 수신 콜백 호출")
    print("====================================")

    guard let fcmToken else {
      print("⚠️ [FCM] 토큰이 nil")
      print("====================================\n")
      return
    }

    #if DEBUG
      print("📋 [FCM] 토큰: \(fcmToken.prefix(50))...")
    #endif

    // 등록된 사용자인지 확인
    guard let userId = Keychain.getString(for: KeychainKey.userId),
          let deviceSecret = Keychain.getString(for: KeychainKey.deviceSecret) else {
      // 미등록 사용자는 registerIfNeeded()에서 토큰과 함께 등록됨
      print("ℹ️ [FCM] 미등록 사용자 - 서버 업데이트 생략 (추후 등록 시 전송)")
      print("====================================\n")
      return
    }

    // 등록된 사용자면 서버에 현재 토큰 전송
    // NOTE: 토큰 변경 여부와 관계없이 항상 전송
    // - 서버는 동일 토큰이면 무시하거나 updated_at만 갱신
    // - 변경됐으면 새 토큰으로 업데이트
    let deviceModel = UIDevice.current.modelIdentifier
    print("📤 [FCM] 서버에 토큰 업데이트 요청 (userId: \(userId), model: \(deviceModel))")
    apiService.updateFCMToken(userId: userId, deviceSecret: deviceSecret, fcmToken: fcmToken, model: deviceModel)
      .sink(
        receiveCompletion: { completion in
          switch completion {
          case .finished:
            print("✅ [FCM] 서버 토큰 업데이트 성공")
          case let .failure(error):
            print("❌ [FCM] 서버 토큰 업데이트 실패: \(error)")
          }
          print("====================================\n")
        },
        receiveValue: { _ in }
      )
      .store(in: &cancellables)
  }

  // 9. APNs 등록에 성공하여 deviceToken을 받았을 때
  // (FCM이 APNs 토큰을 자동으로 FCM 토큰으로 매핑하므로 이 함수 자체는 필수)
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("✅ [APNs] 기기 등록 성공")
    hasRegisteredForRemoteNotifications = true
    Messaging.messaging().apnsToken = deviceToken
  }

  // 10. APNs 등록에 실패했을 때
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("❌ [APNs] 기기 등록 실패: \(error.localizedDescription)")
    // 실패해도 다음에 다시 시도할 수 있도록 플래그는 유지
  }
}

@main
struct TodaySSoundApp: App {
  @StateObject private var session = SessionStore()
  @StateObject private var appTheme = AppThemeManager()

  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup {
      Group {
        if session.isRegistered {
          MainView()
        } else {
          OnBoardingView()
        }
      }
      .environmentObject(session)
      .environmentObject(appTheme)
    }
  }
}
