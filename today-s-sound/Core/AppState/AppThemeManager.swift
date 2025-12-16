//
//  AppThemeManager.swift
//  today-s-sound
//
//  Created by Assistant
//

import SwiftUI

/// 앱 테마 모드
enum AppTheme: String, CaseIterable {
  case normal
  case highContrast
}

/// 앱 테마 관리자
/// 시스템 다크모드 대신 앱 자체의 고대비/일반 모드를 관리합니다.
@MainActor
final class AppThemeManager: ObservableObject {
  @Published var theme: AppTheme {
    didSet {
      print("AppThemeManager - theme 변경됨: \(oldValue) -> \(theme)")
      UserDefaults.standard.set(theme.rawValue, forKey: "appTheme")
    }
  }

  init() {
    // UserDefaults에서 저장된 테마 불러오기
    if let savedTheme = UserDefaults.standard.string(forKey: "appTheme"),
       let theme = AppTheme(rawValue: savedTheme)
    {
      self.theme = theme
    } else {
      // 기본값은 고대비 모드
      theme = .highContrast
    }
  }

  /// 고대비 모드 활성화 여부
  var isHighContrast: Bool {
    theme == .highContrast
  }

  /// 테마 토글
  func toggleTheme() {
    print("AppThemeManager - toggleTheme 호출됨, 현재 테마: \(theme)")
    theme = theme == .normal ? .highContrast : .normal
    print("AppThemeManager - toggleTheme 완료, 새 테마: \(theme)")
  }
}
