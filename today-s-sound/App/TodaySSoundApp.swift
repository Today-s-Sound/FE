//
//  TodaySSoundApp.swift
//  today-s-sound
//
//  Created by 하승연 on 9/28/25.
//

import FirebaseCore
import FirebaseMessaging
import SwiftUI
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate { // 3. Delegate 프로토콜 3개 추가

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
    application.registerForRemoteNotifications()

    // 7. FCM 메시징 대리자 설정
    Messaging.messaging().delegate = self

    return true
  }

  // 8. FCM 토큰을 수신했을 때 호출되는 함수 (이 토큰을 Firebase 콘솔에 입력!)
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("====================================")
    print("Firebase (FCM) 등록 토큰: \(fcmToken ?? "토큰 없음")")
    print("====================================")

    // FCM 토큰을 키체인에 저장
    if let fcmToken {
      Keychain.setString(fcmToken, for: KeychainKey.fcmToken)
      print("✅ FCM 토큰을 키체인에 저장했습니다")
    }
  }

  // 9. APNs 등록에 성공하여 deviceToken을 받았을 때
  // (FCM이 APNs 토큰을 자동으로 FCM 토큰으로 매핑하므로 이 함수 자체는 필수)
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("APNs device token: \(deviceToken)")
    Messaging.messaging().apnsToken = deviceToken
  }

  // 10. APNs 등록에 실패했을 때
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("APNs 등록 실패: \(error.localizedDescription)")
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
