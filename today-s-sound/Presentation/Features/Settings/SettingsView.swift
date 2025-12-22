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
            .accessibilityLabel("관리 화면")

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
            .accessibilityHint("탭하면 구독 페이지 관리 및 추가 화면으로 이동합니다")

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
            .accessibilityHint("탭하면 재생 설정 화면으로 이동합니다")

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
            .accessibilityHint("탭하면 개발자 문의 화면으로 이동합니다")

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
            .accessibilityHint("탭하여 고대비 모드 설정을 변경합니다")
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
          .padding(.horizontal, 8)
          .padding(.bottom, 40)
          .accessibilityLabel("앱 초기화")
          .accessibilityHint("탭하면 앱 초기화 확인 창이 열립니다")

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
    .accessibilityHint("이전 화면으로 돌아가려면 왼쪽 상단의 뒤로가기 버튼을 탭하세요. 보이스오버 사용 중에는 두 손가락으로 Z 모양으로 쓸면 뒤로 갈 수 있습니다.")
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
        .accessibilityHint("탭하면 이전 화면으로 돌아갑니다")

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

// struct SettingsView_Previews: PreviewProvider {
//  static var previews: some View {
//    SettingsView()
//      .environmentObject(SessionStore.preview)
//      .environmentObject(AppThemeManager())
//  }
// }
