//
//  AddSubscriptionButton.swift
//  today-s-sound
//
//  Created by Assistant on 12/19/24.
//

import SwiftUI

struct AddSubscriptionButton: View {
  let colorScheme: ColorScheme
  let onTap: () -> Void

  var body: some View {
    VStack(spacing: 16) {
      Button(action: onTap) {
          Text("새로운 웹페이지 추가")
            .font(.KoddiExtraBold32)
            .foregroundColor(colorScheme == .dark ? .black : .white)
            .padding(.horizontal, 32)
            .padding(.vertical, 18)
            .frame(width: 360, height: 84)
            .background(
              RoundedRectangle(cornerRadius: 10)
                .fill(Color.primaryGreen)
            )
            .foregroundColor(.white)
      }
    }
    .padding(.horizontal, 16)
    .padding(.bottom, 16)
  }
}

struct AddSubscriptionButton_Previews: PreviewProvider {
  static var previews: some View {
    AddSubscriptionButton(colorScheme: .light, onTap: {})
      .previewLayout(.sizeThatFits)
      .padding()
      .background(Color(UIColor.systemBackground))
  }
}
