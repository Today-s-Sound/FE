//
//  KeywordCheckboxRow.swift
//  today-s-sound
//
//  Created by Assistant on 12/19/24.
//

import SwiftUI

// 키워드 체크박스 Row 컴포넌트
struct KeywordCheckboxRow: View {
  let keyword: String
  let isSelected: Bool
  let colorScheme: ColorScheme
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 16) {
        // 체크박스
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

        // 키워드 텍스트
        Text(keyword)
          .font(.custom("KoddiUD OnGothic Regular", size: 18))
          .foregroundColor(Color.text(colorScheme))

        Spacer()
      }
      .padding(.vertical, 16)
      .padding(.horizontal, 20)
    }
    .buttonStyle(PlainButtonStyle())
  }
}
