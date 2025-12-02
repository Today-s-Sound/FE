import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var session: SessionStore
  @Environment(\.colorScheme) var colorScheme
  @State private var showDeleteAlert = false

  var body: some View {
    NavigationView {
      ZStack {
        Color.background(colorScheme)
          .ignoresSafeArea()

        VStack(spacing: 0) {
          ScreenMainTitle(text: "설정", colorScheme: colorScheme)
            .padding(.top, 16)

          Spacer()

          // 회원탈퇴 버튼
          Button {
            showDeleteAlert = true
          } label: {
            Text("회원탈퇴")
              .font(.KoddiBold20)
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 16)
              .background(Color.urgentPink)
              .cornerRadius(8)
          }
          .padding(.horizontal, 20)
          .padding(.bottom, 40)
          .accessibilityLabel("회원탈퇴 버튼")
          .accessibilityHint("탭하여 회원탈퇴를 진행합니다")
        }
      }
      .navigationBarHidden(true)
      .alert("회원탈퇴", isPresented: $showDeleteAlert) {
        Button("취소", role: .cancel) {}
        Button("탈퇴하기", role: .destructive) {
          session.logout()
        }
      } message: {
        Text("정말 회원탈퇴를 하시겠습니까?\n모든 데이터가 삭제됩니다.")
      }
    }
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
      .environmentObject(SessionStore.preview)
  }
}

