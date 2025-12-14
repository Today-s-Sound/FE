//
//  StatusBadge.swift
//  today-s-sound
//
//  Created by Assistant on 12/19/24.
//

import SwiftUI

struct StatusBadge: View {
  let text: String
  let theme: AppTheme
  // theme 파라미터는 현재 사용되지 않지만, 향후 테마 적용을 위해 유지

  var body: some View {
    Text(text)
      .font(.KoddiBold14)
      .foregroundColor(.primaryGreen)
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background(
        RoundedRectangle(cornerRadius: 20)
          .fill(Color.badgeGreenBackground)
      )
      .accessibilityLabel("키워드: \(text)")
  }
}

struct StatusBadge_Previews: PreviewProvider {
  static var previews: some View {
    VStack(spacing: 16) {
      StatusBadge(text: "등록중", theme: .normal)
      StatusBadge(text: "일이삼사", theme: .highContrast)
    }
    .padding()
  }
}
