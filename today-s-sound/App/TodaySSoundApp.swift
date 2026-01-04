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
import UserNotifications

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
    // FCM 토큰이 있으면 = 이미 APNs 등록 완료 + FCM 토큰 생성 완료
    // 따라서 APNs를 다시 등록할 필요 없음
    let hasFCMToken = Keychain.getString(for: KeychainKey.fcmToken) != nil
    
    if hasFCMToken {
      // FCM 토큰이 있으면 이미 APNs도 등록되어 있고 FCM 토큰도 생성되어 있음
      // APNs를 다시 등록할 필요 없음
      print("ℹ️ [APNs] FCM 토큰이 이미 있으므로 APNs 등록 생략 (이미 등록 완료)")
    } else if !hasRegisteredForRemoteNotifications {
      // FCM 토큰이 없고, 아직 등록 요청하지 않았으면 등록 요청
      // APNs 등록 → deviceToken → FCM 토큰 생성 순서로 진행됨
      print("📱 [APNs] 기기 등록 요청 (FCM 토큰이 없으므로 등록 필요)")
      application.registerForRemoteNotifications()
    } else {
      // 이미 등록 요청했지만 아직 완료되지 않음
      print("ℹ️ [APNs] 이미 등록 요청했으므로 대기 중")
    }

    // 7. FCM 메시징 대리자 설정
    Messaging.messaging().delegate = self

    return true
  }

  // 8. FCM 토큰을 수신했을 때 호출되는 함수 (이 토큰을 Firebase 콘솔에 입력!)
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("====================================")
    print("🔔 [FCM] 토큰 수신 콜백 호출")
    print("====================================")
    print("Firebase (FCM) 등록 토큰: \(fcmToken ?? "토큰 없음")")
    
    guard let fcmToken else {
      print("⚠️ FCM 토큰이 nil이므로 저장하지 않음")
      print("====================================\n")
      return
    }
    
    // 기존 토큰 확인
    let existingToken = Keychain.getString(for: KeychainKey.fcmToken)
    
    #if DEBUG
      if let existingToken = existingToken {
        print("📋 [FCM] 저장 전 기존 토큰: \(existingToken.prefix(50))...")
      } else {
        print("📋 [FCM] 저장 전 기존 토큰: (없음)")
      }
    #endif
    
    // 등록된 사용자인지 먼저 확인
    let userId = Keychain.getString(for: KeychainKey.userId)
    let deviceSecret = Keychain.getString(for: KeychainKey.deviceSecret)
    let isRegistered = userId != nil && deviceSecret != nil
    
    // 등록되지 않은 사용자면 FCM 토큰 저장하지 않음 (앱 초기화 후 상태)
    guard isRegistered else {
      print("ℹ️ [FCM] 등록되지 않은 사용자 - FCM 토큰 저장하지 않음 (앱 초기화 상태)")
      print("====================================\n")
      return
    }
    
    // 토큰이 실제로 변경되었는지 확인
    let isTokenChanged = existingToken != fcmToken
    
    if isTokenChanged {
      // 토큰이 변경되었을 때만 저장
      let saved = Keychain.setString(fcmToken, for: KeychainKey.fcmToken)
      if saved {
        print("✅ FCM 토큰이 변경되어 키체인에 저장했습니다")
        
        // 이미 등록된 사용자이므로 서버에 토큰 업데이트
        if let userId = userId, let deviceSecret = deviceSecret {
          print("📤 [FCM] 서버에 FCM 토큰 업데이트 요청 (userId: \(userId))")
          apiService.updateFCMToken(userId: userId, deviceSecret: deviceSecret, fcmToken: fcmToken)
            .sink(
              receiveCompletion: { completion in
                switch completion {
                case .finished:
                  print("✅ [FCM] 서버 토큰 업데이트 성공")
                case let .failure(error):
                  print("❌ [FCM] 서버 토큰 업데이트 실패: \(error)")
                }
              },
              receiveValue: { _ in }
            )
            .store(in: &cancellables)
        }
      } else {
        print("❌ FCM 토큰 저장 실패!")
      }
    } else {
      // 동일한 토큰이면 저장 생략
      print("ℹ️ [FCM] 동일한 토큰이므로 저장 생략")
    }
    
    print("====================================\n")
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
