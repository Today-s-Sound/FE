//
//  EmptyStateView.swift
//  today-s-sound
//
//  Created by Assistant on 12/19/24.
//

import SwiftUI

struct EmptyStateView: View {
  let message: String
  let colorScheme: ColorScheme

  var body: some View {
    VStack(spacing: 12) {
      Image(systemName: "tray")
        .font(.system(size: 40, weight: .regular))
        .foregroundColor(Color.secondaryText(colorScheme))
      Text(message)
        .foregroundColor(Color.secondaryText(colorScheme))
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

struct EmptyStateView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      EmptyStateView(
        message: "구독 중인 페이지가 없어요.",
        colorScheme: .light
      )
      .previewDisplayName("Light")

      EmptyStateView(
        message: "최근 알림이 없어요.",
        colorScheme: .dark
      )
      .previewDisplayName("Dark")
      .background(Color.black)
    }
    .previewLayout(.sizeThatFits)
    .padding()
  }
}
