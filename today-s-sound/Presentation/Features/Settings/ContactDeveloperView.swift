import SwiftUI

struct ContactDeveloperView: View {
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.dismiss) var dismiss
  @State private var emailSubject = ""
  @State private var emailBody = ""

  var body: some View {
    ZStack {
      Color.background(colorScheme)
        .ignoresSafeArea()

      VStack(spacing: 0) {
        ScreenMainTitle(text: "개발자 문의", colorScheme: colorScheme)
          .padding(.top, 16)

        Spacer()

        VStack(spacing: 24) {

          // 문의 안내 텍스트
          VStack(spacing: 12) {
            Text("문의사항이 있으신가요?")
              .font(.KoddiBold20)
              .foregroundColor(Color.text(colorScheme))
              .accessibilityLabel("문의사항이 있으신가요?")

            Text("아래 이메일로 문의해주세요.")
              .font(.KoddiRegular16)
              .foregroundColor(Color.secondaryText(colorScheme))
              .accessibilityLabel("아래 이메일로 문의해주세요.")
          }

          // 이메일 주소 버튼
          Button {
            if let url = URL(string: "mailto:support@todayssound.com?subject=문의사항") {
              UIApplication.shared.open(url)
            }
          } label: {
            HStack(spacing: 8) {
              Image(systemName: "envelope")
                .font(.KoddiBold20)
                .foregroundColor(Color.primaryGreen)
              Text("support@todayssound.com")
                .font(.KoddiBold20)
                .foregroundColor(Color.primaryGreen)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .overlay(
              RoundedRectangle(cornerRadius: 8)
                .stroke(Color.primaryGreen, lineWidth: 2)
            )
          }
          .buttonStyle(PlainButtonStyle())
          .accessibilityLabel("이메일 보내기 버튼")
          .accessibilityHint("탭하여 이메일 앱을 엽니다")
        }
        .padding(.horizontal, 20)

        Spacer()
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button {
          dismiss()
        } label: {
          Image(systemName: "chevron.left")
            .font(.KoddiBold20)
            .foregroundColor(Color.text(colorScheme))
        }
        .accessibilityLabel("뒤로 가기")
        .accessibilityHint("관리 페이지로 돌아갑니다")
      }
    }
  }
}

struct ContactDeveloperView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      ContactDeveloperView()
    }
  }
}

