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
          Button(action: {
            Task {
              isLoading = true
              defer { isLoading = false }
              await session.registerIfNeeded()
            }
          }) {
            Text("시작하기")
              .font(.KoddiExtraBold32)
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 16)
              .background(Color.primaryGreen)
              .cornerRadius(8)
          }
          .padding(.horizontal, 32)
          .padding(.bottom, 40)
          .accessibilityLabel("시작하기 버튼")
          .accessibilityHint("탭하면 앱을 시작합니다")
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

struct OnBoardingView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      OnBoardingView()
        .environmentObject(SessionStore.preview)
        .environmentObject(AppThemeManager())

      OnBoardingView()
        .environmentObject(SessionStore.preview)
        .environmentObject({
          let manager = AppThemeManager()
          manager.theme = .highContrast
          return manager
        }())
    }
  }
}
