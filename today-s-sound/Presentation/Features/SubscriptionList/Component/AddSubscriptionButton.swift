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
    VStack(spacing: 12) {
      Button(action: onTap) {
        HStack {
          Image(systemName: "plus.circle.fill")
            .font(.system(size: 18))
          Text("새로운 웹페이지 추가")
            .font(.system(size: 24, weight: .semibold))
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
          RoundedRectangle(cornerRadius: 12)
            .fill(Color.primaryGreen90)
        )
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
