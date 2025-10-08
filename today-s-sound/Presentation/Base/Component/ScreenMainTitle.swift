//
//  ScreenSection.swift
//  today-s-sound
//
//  Created by 박지현 on 10/8/25.
//

import SwiftUI

/// 공통 타이틀 컴포넌트. 다양한 화면에서 재사용 가능
struct ScreenMainTitle: View {
    let text: String
    let colorScheme: ColorScheme

    var body: some View {
        Text(text)
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(Color.text(colorScheme))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
    }
}

struct ScreenSectionTitle_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            ScreenMainTitle(text: "최근 알림", colorScheme: .light)
            ScreenMainTitle(text: "구독 설정", colorScheme: .light)
        }
        .padding()
    }
}
