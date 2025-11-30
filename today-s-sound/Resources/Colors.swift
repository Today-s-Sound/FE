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
  /// 배경색 (다크모드 대응)
  static func background(_ colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? .black : .white
  }

  /// 보조 배경색 (다크모드 대응)
  static func secondaryBackground(_ colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? Color(white: 0.15) : Color(white: 0.95)
  }

  /// 텍스트 색상 (다크모드 대응)
  static func text(_ colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? .white : .black
  }

  /// 보조 텍스트 색상 (다크모드 대응)
  static func secondaryText(_ colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.6)
  }

  /// 테두리 색상 (다크모드 대응)
  static func border(_ colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? .white.opacity(0.2) : .gray.opacity(0.3)
  }

  /// 버튼 배경색 (다크모드 대응)
  static func buttonBackground(_ colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? .black : .white
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
