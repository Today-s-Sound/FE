import SwiftUI

struct AddSubscriptionView: View {
  @StateObject private var viewModel = AddSubscriptionViewModel()
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.dismiss) var dismiss

  var body: some View {
    ZStack {
      Color.background(colorScheme)
        .ignoresSafeArea()

      VStack(spacing: 0) {
        HeaderBar(colorScheme: colorScheme, onClose: { dismiss() })

        ScreenSubTitle(text: "새 웹페이지 추가", colorScheme: colorScheme)

        ScrollView {
          VStack(spacing: 24) {
            InputFieldSection(
              title: "웹사이트 URL",
              placeholder: "https://www.example.com",
              description: "모니터링 할 웹페이지 URL을 입력하세요.",
              text: $viewModel.urlText,
              colorScheme: colorScheme
            )

            InputFieldSection(
              title: "웹페이지 별명",
              placeholder: "동국대학교 공지사항",
              description: "웹 페이지를 식별할 명칭을 입력하세요.",
              text: $viewModel.nameText,
              colorScheme: colorScheme
            )

            InputFieldSection(
              title: "키워드 필터",
              placeholder: "장학금, 교직, 학생회",
              description: "관심 키워드가 포함된 내용을 걸러낼 필요가 있으면 입력하세요.",
              text: $viewModel.keywordsText,
              colorScheme: colorScheme,
              additionalContent: {
                AnyView(
                  HStack(spacing: 8) {
                    KeywordBadge(text: "장학금", colorScheme: colorScheme)
                    KeywordBadge(text: "교직부공지사항", colorScheme: colorScheme)
                  }
                )
              }
            )

            UrgentToggleRow(isOn: $viewModel.isUrgent, colorScheme: colorScheme)

            // 하단 버튼
            Button(action: {
              dismiss()
            }, label: {
              Text("등록 승인 요청")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                  RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primaryGreen90)
                )
            })
          }
          .padding(.horizontal, 16)
          .padding(.top, 8)
          .padding(.bottom, 16)
        }
      }
    }
  }
}

struct AddSubscriptionView_Previews: PreviewProvider {
  static var previews: some View {
    AddSubscriptionView()
  }
}
