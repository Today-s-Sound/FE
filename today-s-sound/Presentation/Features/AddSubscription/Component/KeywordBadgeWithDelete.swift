//
//  KeywordBadgeWithDelete.swift
//  today-s-sound
//
//  삭제 버튼이 있는 키워드 배지 컴포넌트
//

import SwiftUI

/// 삭제 버튼이 있는 키워드 배지
struct KeywordBadgeWithDelete: View {
  let text: String
  let theme: AppTheme
  let onDelete: () -> Void
  // theme 파라미터는 현재 사용되지 않지만, 향후 테마 적용을 위해 유지

  var body: some View {
    HStack(spacing: 6) {
      Text(text)
        .font(.KoddiBold14)
        .foregroundColor(.primaryGreen)

      Button(action: onDelete) {
        Image(systemName: "xmark")
          .font(.KoddiBold14)
          .foregroundColor(.primaryGreen)
      }
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(
      RoundedRectangle(cornerRadius: 20)
        .fill(Color.badgeGreenBackground)
    )
    .overlay(
      RoundedRectangle(cornerRadius: 20)
        .stroke(Color.primaryGreen, lineWidth: 1)
    )
    .accessibilityElement(children: .combine)
    .accessibilityLabel("선택된 키워드: \(text)")
    .accessibilityHint("탭하여 이 키워드 추가를 취소합니다")
  }
}

