//
//  OnBoardingView.swift
//  today-s-sound
//
//  Created by 하승연 on 10/30/25.
//

import SwiftUI

struct OnBoardingView: View {
  @EnvironmentObject var session: SessionStore
  @Environment(\.colorScheme) private var colorScheme
  @State private var isLoading = false
  @State private var didStartRegistration = false

  var body: some View {
    ZStack {
      VStack(spacing: 100) {
        Text("오늘의 소리")
          .font(.KoddiBold56)
          .foregroundColor(colorScheme == .dark ? .white : .black)
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
        if let err = session.lastError {
          Text(err)
            .foregroundStyle(.red)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .accessibilityLabel("오류: \(err)")
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(colorScheme == .dark ? Color.black : Color.white)
    .task {
      guard !didStartRegistration else { return }
      didStartRegistration = true
      isLoading = true
      defer { isLoading = false }
      await session.registerIfNeeded()
    }
  }
}

struct OnBoardingView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      OnBoardingView()
        .environmentObject(SessionStore.preview)
        .preferredColorScheme(.light)

      OnBoardingView()
        .environmentObject(SessionStore.preview)
        .preferredColorScheme(.dark)
    }
  }
}
