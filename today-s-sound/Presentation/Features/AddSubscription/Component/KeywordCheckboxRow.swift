//
//  KeywordCheckboxRow.swift
//  today-s-sound
//

import SwiftUI

/// 키워드 한 줄(체크박스 + 텍스트)
struct KeywordCheckboxRow: View {
  let keyword: String
  let isSelected: Bool
  let theme: AppTheme
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 16) {
        ZStack {
          RoundedRectangle(cornerRadius: 6)
            .stroke(isSelected ? Color.primaryGreen : Color.border(theme), lineWidth: 2)
            .frame(width: 28, height: 28)

          if isSelected {
            RoundedRectangle(cornerRadius: 6)
              .fill(Color.primaryGreen)
              .frame(width: 28, height: 28)

            Image(systemName: "checkmark")
              .font(.system(size: 16, weight: .bold))
              .foregroundColor(.white)
          }
        }
        .accessibilityHidden(true)

        Text(keyword)
          .font(.KoddiBold20)
          .foregroundColor(Color.text(theme))

        Spacer()
      }
      .padding(.vertical, 16)
      .padding(.horizontal, 20)
    }
    .buttonStyle(PlainButtonStyle())
    .accessibilityValue(isSelected ? "선택됨" : "선택 안 됨")
    .accessibilityHint("탭하여 이 키워드를 선택하거나 해제합니다")
  }
}
