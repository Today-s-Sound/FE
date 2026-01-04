import SwiftUI
import UIKit

struct ContactDeveloperView: View {
  @EnvironmentObject var appTheme: AppThemeManager
  @Environment(\.dismiss) var dismiss

  private let emailAddress = "todaysound.official@gmail.com"

  @State private var showToast = false

  var body: some View {
    ZStack {
      Color.background(appTheme.theme)
        .ignoresSafeArea()

      VStack(spacing: 0) {
        Spacer()

        VStack(spacing: 24) {
          VStack(spacing: 12) {
            Text("문의사항이 있으신가요?")
              .font(.KoddiBold20)
              .foregroundColor(Color.text(appTheme.theme))

            Text("웹사이트와 키워드 추가, 기타 요청사항은\n아래 이메일로 문의해주세요.")
              .font(.KoddiRegular16)
              .foregroundColor(Color.secondaryText(appTheme.theme))
              .multilineTextAlignment(.center)
          }
          .accessibilityElement(children: .combine)
          .accessibilityLabel("문의사항이 있으신가요? 웹사이트와 키워드 추가, 기타 요청사항은 아래 이메일로 문의해주세요.")

          Button {
            copyEmailToClipboard()
          } label: {
            HStack(spacing: 8) {
              Image(systemName: "envelope")
                .font(.KoddiBold20)
                .foregroundColor(Color.primaryGreen)

              Text(emailAddress)
                .font(.KoddiBold20)
                .foregroundColor(Color.primaryGreen)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
            .padding(.vertical, 16)
            .overlay(
              RoundedRectangle(cornerRadius: 8)
                .stroke(Color.primaryGreen, lineWidth: 2)
            )
          }
          .buttonStyle(PlainButtonStyle())
          .accessibilityLabel(emailAddress)
          .accessibilityHint("더블 탭하면 이메일 주소를 클립보드에 복사합니다. t,o,d,a,y,s,o,u,n,d,.,o,f,f,i,c,i,a,l,@,g,m,a,i,l.c,o,m")
        }
        .padding(.horizontal, 20)

        Spacer()
      }

      // 토스트(시각용). VoiceOver는 announcement로 안내하므로 중복 방지 위해 숨김
      if showToast {
        toastView
          .transition(.opacity)
          .accessibilityHidden(true)
      }
    }
  }

  private var toastView: some View {
    Text("이메일 주소가 복사되었습니다")
      .font(.KoddiRegular16)
      .foregroundColor(Color.text(appTheme.theme))
      .padding(.horizontal, 14)
      .padding(.vertical, 10)
      .background(
        RoundedRectangle(cornerRadius: 10)
          .fill(Color.secondaryBackground(appTheme.theme))
      )
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .stroke(Color.border(appTheme.theme), lineWidth: 1)
      )
      .padding(.horizontal, 20)
      .padding(.bottom, 24)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
  }

  private func copyEmailToClipboard() {
    // 클립보드 복사
    UIPasteboard.general.string = emailAddress

    // VoiceOver 사용자에게 즉시 피드백 (토스트와 중복 낭독 방지: 토스트는 accessibilityHidden 처리)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        UIAccessibility.post(
          notification: .announcement,
          argument: "이메일 주소가 클립보드에 복사되었습니다."
        )
      }
    // 시각 토스트 표시
    withAnimation(.easeInOut(duration: 0.15)) {
      showToast = true
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
      withAnimation(.easeInOut(duration: 0.15)) {
        showToast = false
      }
    }
  }
}
