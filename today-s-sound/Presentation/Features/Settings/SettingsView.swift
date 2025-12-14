import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var session: SessionStore
  @Environment(\.colorScheme) var colorScheme
  @State private var showDeleteAlert = false
  @AppStorage("highContrastMode") private var highContrastMode = false

  var body: some View {
    NavigationView {
      ZStack {
        Color.background(colorScheme)
          .ignoresSafeArea()

        VStack(spacing: 0) {
          ScreenMainTitle(text: "관리", colorScheme: colorScheme)
            .padding(.top, 16)

          Spacer()

          // 관리 항목 리스트
          VStack(spacing: 0) {
            NavigationLink(destination: SubscriptionListView()) {
              SettingsRow(title: "구독 페이지 관리", colorScheme: colorScheme)
            }
            .buttonStyle(PlainButtonStyle())

            Divider()
              .background(Color.border(colorScheme))
              .padding(.horizontal, 20)

            NavigationLink(destination: PlaybackSettingsView()) {
              SettingsRow(title: "재생 설정", colorScheme: colorScheme)
            }
            .buttonStyle(PlainButtonStyle())

            Divider()
              .background(Color.border(colorScheme))
              .padding(.horizontal, 20)

            NavigationLink(destination: ContactDeveloperView()) {
              SettingsRow(title: "개발자에게 문의", colorScheme: colorScheme)
            }
            .buttonStyle(PlainButtonStyle())

            Divider()
              .background(Color.border(colorScheme))
              .padding(.horizontal, 20)

            HStack {
              Text("고대비 모드 설정")
                .font(.KoddiBold24)
                .foregroundColor(Color.text(colorScheme))
              Spacer()
              Toggle("", isOn: $highContrastMode)
                .labelsHidden()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("고대비 모드 설정")
            .accessibilityValue(highContrastMode ? "켜짐" : "꺼짐")
            .accessibilityHint("탭하여 고대비 모드 설정을 변경합니다")
          }
          .background(Color.background(colorScheme))
          .cornerRadius(12)
          .padding(.horizontal, 20)
          .padding(.bottom, 40)

          // 앱 초기화 버튼
          Button {
            showDeleteAlert = true
          } label: {
            Text("앱 초기화")
              .font(.KoddiBold20)
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 16)
              .background(Color.urgentPink)
              .cornerRadius(8)
          }
          .padding(.horizontal, 20)
          .padding(.bottom, 40)
          .accessibilityLabel("앱 초기화 버튼")
          .accessibilityHint("탭하여 앱을 초기화합니다")

          Spacer()
        }
      }
      .navigationBarHidden(true)
      .alert("앱 초기화", isPresented: $showDeleteAlert) {
        Button("취소", role: .cancel) {}
        Button("초기화하기", role: .destructive) {
          session.logout()
          // 앱 종료
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exit(0)
          }
        }
      } message: {
        Text("정말 앱을 초기화하시겠습니까?\n모든 데이터가 삭제되고 앱이 종료됩니다.")
      }
    }
  }
}

// MARK: - Settings Row Component

struct SettingsRow: View {
  let title: String
  let colorScheme: ColorScheme

  var body: some View {
    HStack {
      Text(title)
        .font(.KoddiBold24)
        .foregroundColor(Color.text(colorScheme))
      Spacer()
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 16)
    .contentShape(Rectangle())
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
      .environmentObject(SessionStore.preview)
  }
}
