//
//  ScreenSubTitle.swift
//  today-s-sound
//
//  Created by Assistant on 12/19/24.
//

import SwiftUI

struct ScreenSubTitle: View {
  let text: String
  let colorScheme: ColorScheme

  var body: some View {
    Text(text)
      .font(.KoddiExtraBold28)
      .foregroundColor(colorScheme == .dark ? .white : .primaryGreen)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, 24)
      .padding(.bottom, 16)
  }
}

struct ScreenTitle_Previews: PreviewProvider {
  static var previews: some View {
    VStack(spacing: 0) {
      ScreenSubTitle(text: "새 웹페이지 추가", colorScheme: .light)
      ScreenSubTitle(text: "새 웹페이지 추가", colorScheme: .dark)
    }
  }
}
