//
//  OnBoardingView.swift
//  today-s-sound
//
//  Created by 하승연 on 10/30/25.
//

import SwiftUI

struct OnBoardingView: View {
  @EnvironmentObject var session: SessionStore
  @State private var isLoading = false

  var body: some View {
    VStack(spacing: 20) {
      Text("환영합니다 👋")
        .font(.largeTitle).bold()
      Text("이 기기를 익명 사용자로 등록하고 서비스를 시작합니다.")
        .multilineTextAlignment(.center)
        .foregroundStyle(.secondary)

      if isLoading {
        ProgressView("등록 중…")
          .padding(.top, 8)
      } else {
        Button {
          Task {
            isLoading = true
            defer { isLoading = false }
            await session.registerIfNeeded()
          }
        } label: {
          Text("시작하기")
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.top, 12)
      }

      if let err = session.lastError {
        Text(err)
          .foregroundStyle(.red)
          .multilineTextAlignment(.center)
          .padding(.top, 8)
      }

      // 디버그: 생성된 deviceSecret 미리보기(실서비스에서는 숨기기)
      // if let s = Keychain.getString(for: KeychainKey.deviceSecret) {
      //     Text("secret: \(s)").font(.footnote).foregroundStyle(.secondary)
      // }
    }
    .padding(24)
  }
}
