//
//  OnBoardingView.swift
//  today-s-sound
//
//  Created by 하승연 on 10/30/25.
//

import SwiftUI

struct OnBoardingView: View {
  @EnvironmentObject var session: SessionStore
  @EnvironmentObject var appTheme: AppThemeManager
  @State private var isLoading = false

  var body: some View {
    ZStack {
      VStack(spacing: 100) {
        Text("오늘의 소리")
          .font(.KoddiBold56)
          .foregroundColor(Color.text(appTheme.theme))
          .accessibilityAddTraits(.isHeader)

        VStack(spacing: 20) {
          Image("play")
            .resizable()
            .scaledToFit()
            .frame(width: 180, height: 180)
            .accessibilityLabel("오늘의 소리 로고")

          if isLoading {
            ProgressView("초기화 중…")
              .accessibilityLabel("초기화 중입니다")
              .accessibilityHint("잠시만 기다려주세요")
          }
        }
      }
      .multilineTextAlignment(.center)
      .padding(.horizontal, 32)
      .offset(y: -80)

      VStack {
        Spacer()

        // 시작하기 버튼
        if !isLoading {
            MainButton(
              title: "시작하기",
              theme: appTheme.theme,
              isEnabled: true
            ) {
                Task {
                  isLoading = true
                  defer { isLoading = false }
                  await session.registerIfNeeded()
                }
            }
            .accessibilityLabel("시작하기")
            .accessibilityHint("앱을 시작합니다")
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .padding(.bottom, 20)
        }

        // 에러 메시지
        if let err = session.lastError {
          Text(err)
            .foregroundStyle(.red)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            .padding(.bottom, isLoading ? 24 : 0)
            .accessibilityLabel("오류: \(err)")
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.background(appTheme.theme))
  }
}
