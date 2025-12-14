//
//  Colors.swift
//  today-s-sound
//
//  Created by 하승연 on 18/11/25.
//

import SwiftUI

// MARK: - Brand Colors

extension Color {
  /// 메인 브랜드 그린 색상 (Primary Green)
  static let primaryGreen = Color(red: 0 / 255, green: 223 / 255, blue: 119 / 255)

  /// 긴급 알림 핑크 색상 (Urgent Pink)
  static let urgentPink = Color(red: 255 / 255, green: 76 / 255, blue: 186 / 255)

  /// 배지 배경 그린 색상 (Badge Background Green)
  static let badgeGreenBackground = Color(red: 52 / 255, green: 199 / 255, blue: 89 / 255, opacity: 0.16)

  /// 구독 페이지 목록 배경
  static let greyBackground = Color(red: 245 / 255, green: 245 / 255, blue: 245 / 255)

  /// 구독 페이지 목록 폰트
  static let primaryGrey = Color(red: 51 / 255, green: 51 / 255, blue: 51 / 255)

  /// 새 페이지 추가 입력
  static let secondaryGrey = Color(red: 115 / 255, green: 115 / 255, blue: 115 / 255)

  /// 페이지 목록 테두리
  static let borderGrey = Color(red: 197 / 255, green: 197 / 255, blue: 197 / 255)
}

// MARK: - Semantic Colors

extension Color {
  /// 배경색 (앱 테마 기반)
  static func background(_ theme: AppTheme) -> Color {
    theme == .highContrast ? .black : .white
  }

  /// 보조 배경색 (앱 테마 기반)
  static func secondaryBackground(_ theme: AppTheme) -> Color {
    theme == .highContrast ? Color(white: 0.15) : Color(white: 0.95)
  }

  /// 텍스트 색상 (앱 테마 기반)
  static func text(_ theme: AppTheme) -> Color {
    theme == .highContrast ? .white : .black
  }

  /// 보조 텍스트 색상 (앱 테마 기반)
  static func secondaryText(_ theme: AppTheme) -> Color {
    theme == .highContrast ? .white.opacity(0.6) : .black.opacity(0.6)
  }

  /// 테두리 색상 (앱 테마 기반)
  static func border(_ theme: AppTheme) -> Color {
    theme == .highContrast ? .white.opacity(0.2) : .gray.opacity(0.3)
  }

  /// 버튼 배경색 (앱 테마 기반)
  static func buttonBackground(_ theme: AppTheme) -> Color {
    theme == .highContrast ? .black : .white
  }

  // MARK: - 기존 호환성을 위한 ColorScheme 기반 메서드 (deprecated)
  // 기존 코드와의 호환성을 위해 유지하되, 내부적으로는 AppThemeManager를 사용하도록 권장

  /// 배경색 (다크모드 대응) - deprecated: AppTheme 사용 권장
  @available(*, deprecated, message: "Use background(_ theme: AppTheme) instead")
  static func background(_ colorScheme: ColorScheme) -> Color {
    .white
  }

  /// 보조 배경색 (다크모드 대응) - deprecated: AppTheme 사용 권장
  @available(*, deprecated, message: "Use secondaryBackground(_ theme: AppTheme) instead")
  static func secondaryBackground(_ colorScheme: ColorScheme) -> Color {
    Color(white: 0.95)
  }

  /// 텍스트 색상 (다크모드 대응) - deprecated: AppTheme 사용 권장
  @available(*, deprecated, message: "Use text(_ theme: AppTheme) instead")
  static func text(_ colorScheme: ColorScheme) -> Color {
    .black
  }

  /// 보조 텍스트 색상 (다크모드 대응) - deprecated: AppTheme 사용 권장
  @available(*, deprecated, message: "Use secondaryText(_ theme: AppTheme) instead")
  static func secondaryText(_ colorScheme: ColorScheme) -> Color {
    .black.opacity(0.6)
  }

  /// 테두리 색상 (다크모드 대응) - deprecated: AppTheme 사용 권장
  @available(*, deprecated, message: "Use border(_ theme: AppTheme) instead")
  static func border(_ colorScheme: ColorScheme) -> Color {
    .gray.opacity(0.3)
  }

  /// 버튼 배경색 (다크모드 대응) - deprecated: AppTheme 사용 권장
  @available(*, deprecated, message: "Use buttonBackground(_ theme: AppTheme) instead")
  static func buttonBackground(_ colorScheme: ColorScheme) -> Color {
    .white
  }
}

// MARK: - Opacity Variants

extension Color {
  /// Primary Green with 20% opacity
  static let primaryGreen20 = Color.primaryGreen.opacity(0.2)

  /// Black with 15% opacity
  static let black15 = Color.black.opacity(0.15)

  /// Black with 25% opacity
  static let black25 = Color.black.opacity(0.25)

  /// Black with 5% opacity
  static let black5 = Color.black.opacity(0.05)
}
