import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var session: SessionStore
  @EnvironmentObject var appTheme: AppThemeManager
  @State private var showDeleteAlert = false

  var body: some View {
    NavigationView {
      ZStack {
        Color.background(appTheme.theme)
          .ignoresSafeArea()

        VStack(spacing: 0) {
          ScreenMainTitle(text: "관리", theme: appTheme.theme)
            .padding(.bottom, 16)
            .accessibilityAddTraits(.isHeader)

          VStack(spacing: 0) {
            NavigationLink(
              destination: BackHeaderContainer(title: "구독 관리", theme: appTheme.theme) {
                SubscriptionListView()
              }
            ) {
              SettingsRow(title: "구독 페이지 관리 및 추가", theme: appTheme.theme)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("구독 페이지 관리 및 추가")
            .accessibilityHint("구독할 웹사이트와 알림을 설정합니다")

            Divider()
              .background(Color.border(appTheme.theme))
              .padding(.horizontal, 4)
              .accessibilityHidden(true)

            NavigationLink(
              destination: BackHeaderContainer(title: "재생 설정", theme: appTheme.theme) {
                PlaybackSettingsView()
              }
            ) {
              SettingsRow(title: "재생 설정", theme: appTheme.theme)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("재생 설정")
            .accessibilityHint("홈 화면에서 재생되는 오늘의 소리 속도를 조절합니다")

            Divider()
              .background(Color.border(appTheme.theme))
              .padding(.horizontal, 4)
              .accessibilityHidden(true)

            NavigationLink(
              destination: BackHeaderContainer(title: "개발자 문의", theme: appTheme.theme) {
                ContactDeveloperView()
              }
            ) {
              SettingsRow(title: "개발자에게 문의", theme: appTheme.theme)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("개발자에게 문의")
            .accessibilityHint("등록하고 싶은 웹사이트나 기타 건의사항을 요청합니다")

            Divider()
              .background(Color.border(appTheme.theme))
              .padding(.horizontal, 4)
              .accessibilityHidden(true)

            HStack {
              Text("고대비 모드 설정")
                .font(.KoddiBold28)
                .foregroundColor(Color.text(appTheme.theme))
              Spacer()
              Toggle("", isOn: Binding(
                get: { appTheme.isHighContrast },
                set: { _ in appTheme.toggleTheme() }
              ))
              .labelsHidden()
              .tint(Color.primaryGreen)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("고대비 모드 설정")
            .accessibilityValue(appTheme.isHighContrast ? "켜짐" : "꺼짐")

            Divider()
              .background(Color.border(appTheme.theme))
              .padding(.horizontal, 4)
              .accessibilityHidden(true)

            NavigationLink(
              destination: BackHeaderContainer(title: "도움말", theme: appTheme.theme) {
                HelpView(theme: appTheme.theme)
              }
            ) {
              SettingsRow(title: "도움말", theme: appTheme.theme)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("도움말")
            .accessibilityHint("앱 사용 방법과 기능을 안내합니다")

            Divider()
              .background(Color.border(appTheme.theme))
              .padding(.horizontal, 4)
              .accessibilityHidden(true)

            NavigationLink(
              destination: BackHeaderContainer(title: "FAQ", theme: appTheme.theme) {
                FAQView(theme: appTheme.theme)
              }
            ) {
              SettingsRow(title: "자주 묻는 질문", theme: appTheme.theme)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("자주 묻는 질문")
            .accessibilityHint("자주 묻는 질문과 답변을 확인합니다")
          }
          .background(Color.background(appTheme.theme))
          .cornerRadius(12)
          .padding(.horizontal, 8)
          .padding(.bottom, 40)
          .accessibilityElement(children: .contain)

          // 앱 초기화 버튼
          Button {
            showDeleteAlert = true
          } label: {
            Text("앱 초기화")
              .font(.KoddiExtraBold32)
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 16)
              .background(Color.urgentPink)
              .cornerRadius(8)
          }
          .padding(.horizontal, 16)
          .padding(.vertical, 16)
          .padding(.bottom, 40)
          .accessibilityLabel("앱 초기화")
          .accessibilityHint("앱의 모든 데이터를 삭제하고 앱을 종료합니다")

          Spacer()
        }
      }
      .navigationBarHidden(true)
      .alert("앱 초기화", isPresented: $showDeleteAlert) {
        Button("취소", role: .cancel) {}
          .accessibilityLabel("취소")

        Button("초기화하기", role: .destructive) {
          session.withdraw()
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { exit(0) }
        }
        .accessibilityLabel("초기화하기")
        .accessibilityHint("모든 데이터를 삭제하고 앱을 종료합니다")
      } message: {
        Text("정말 앱을 초기화하시겠습니까? 서버의 모든 데이터가 삭제되고 앱이 종료됩니다.")
      }
    }
  }
}

// MARK: - 목적지 화면용 커스텀 헤더 래퍼

private struct BackHeaderContainer<Content: View>: View {
  @Environment(\.dismiss) private var dismiss

  let title: String
  let theme: AppTheme
  let content: Content

  init(title: String, theme: AppTheme, @ViewBuilder content: () -> Content) {
    self.title = title
    self.theme = theme
    self.content = content()
  }

  var body: some View {
    ZStack(alignment: .top) {
      Color.background(theme)
        .ignoresSafeArea()

      VStack(spacing: 0) {
        header
        content
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      }
    }
    .navigationBarHidden(true)
  }

  private var header: some View {
    ZStack {
      // 가운데 고정 타이틀
      Text(title)
        .font(.KoddiBold56)
        .foregroundColor(Color.text(theme))
        .lineLimit(1)
        .truncationMode(.tail)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 30) // ← 좌/우 버튼 영역만큼 항상 확보
        .accessibilityAddTraits(.isHeader)

      // 왼쪽 고정 뒤로 버튼
      HStack {
        Button {
          dismiss()
        } label: {
          Image(systemName: "chevron.left")
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(Color.text(theme))
            .frame(width: 44, height: 44)
        }
        .accessibilityLabel("뒤로가기")
        .accessibilityHint("탭하면 관리 화면으로 돌아갑니다")

        Spacer()
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 8)
  }
}

// MARK: - Settings Row Component

struct SettingsRow: View {
  let title: String
  let theme: AppTheme

  var body: some View {
    HStack {
      Text(title)
        .font(.KoddiBold28)
        .foregroundColor(Color.text(theme))
      Spacer()
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 24)
    .contentShape(Rectangle())
  }
}
