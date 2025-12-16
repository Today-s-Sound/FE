//
//  ScreenMainTitle.swift
//  today-s-sound
//
//  Created by 박지현 on 10/8/25.
//

import SwiftUI

/// 공통 타이틀 컴포넌트. 다양한 화면에서 재사용 가능
struct ScreenMainTitle: View {
  let text: String
  let theme: AppTheme

  var body: some View {
    Text(text)
      .font(.KoddiBold56)
      .foregroundColor(Color.text(theme))
      .frame(maxWidth: .infinity, alignment: .center)
      .multilineTextAlignment(.center)
      .padding(.horizontal, 24)
      .padding(.bottom, 16)
      .accessibilityAddTraits(.isHeader)
      .accessibilityLabel(text)
  }
}

struct ScreenSectionTitle_Previews: PreviewProvider {
  static var previews: some View {
    VStack(spacing: 16) {
      ScreenMainTitle(text: "최근 알림", theme: .normal)
      ScreenMainTitle(text: "구독 설정", theme: .normal)
    }
    .padding()
  }
}
