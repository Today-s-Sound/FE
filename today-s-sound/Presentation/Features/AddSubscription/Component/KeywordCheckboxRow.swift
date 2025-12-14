//
//  KeywordCheckboxRow.swift
//  today-s-sound
//

import SwiftUI

/// 키워드 한 줄(체크박스 + 텍스트)
struct KeywordCheckboxRow: View {
  let keyword: String
  let isSelected: Bool
  let colorScheme: AppTheme
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 16) {
        ZStack {
          RoundedRectangle(cornerRadius: 6)
            .stroke(isSelected ? Color.primaryGreen : Color.border(colorScheme), lineWidth: 2)
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
          .foregroundColor(Color.text(colorScheme))

        Spacer()
      }
      .padding(.vertical, 16)
      .padding(.horizontal, 20)
    }
    .buttonStyle(PlainButtonStyle())
    .accessibilityLabel("키워드 \(keyword)")
    .accessibilityValue(isSelected ? "선택됨" : "선택 안 됨")
    .accessibilityHint("탭하여 이 키워드를 선택하거나 해제합니다")
  }
}

struct KeywordCheckboxRow_Previews: PreviewProvider {
  static var previews: some View {
    VStack(spacing: 12) {
      KeywordCheckboxRow(
        keyword: "시각장애",
        isSelected: true,
        colorScheme: .normal,
        action: {}
      )

      KeywordCheckboxRow(
        keyword: "접근성",
        isSelected: false,
        colorScheme: .highContrast,
        action: {}
      )
    }
    .previewLayout(.sizeThatFits)
    .padding()
    .background(Color(UIColor.systemBackground))
  }
}
