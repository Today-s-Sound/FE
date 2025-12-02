//
//  StatusBadge.swift
//  today-s-sound
//
//  Created by Assistant on 12/19/24.
//

import SwiftUI

struct StatusBadge: View {
  let text: String
  let colorScheme: ColorScheme

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
      StatusBadge(text: "등록중", colorScheme: .light)
      StatusBadge(text: "일이삼사", colorScheme: .dark)
    }
    .padding()
  }
}
