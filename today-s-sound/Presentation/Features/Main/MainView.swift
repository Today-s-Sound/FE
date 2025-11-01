import SwiftUI

struct MainView: View {
  @StateObject private var viewModel = MainViewModel()
  @State private var showingDebugSettings = false

  var body: some View {
    TabView {
      HomeView()
        .tabItem {
          Image(systemName: "house.fill")
          Text("메인")
        }

      NotificationListView()
        .tabItem {
          Image(systemName: "bell.fill")
          Text("알림")
        }

      SubscriptionListView()
        .tabItem {
          Image(systemName: "bookmark.fill")
          Text("구독")
        }

      #if DEBUG
        // 디버그 모드에서만 표시
        NavigationView {
          VStack(spacing: 20) {
            Image(systemName: "hammer.fill")
              .font(.system(size: 60))
              .foregroundColor(.orange)

            Text("개발자 도구")
              .font(.title)
              .fontWeight(.bold)

            List {
              Section("테스트") {
                NavigationLink("익명 사용자 등록 테스트") {
                  AnonymousTestView()
                }
              }

              Section("설정") {
                Button(action: {
                  showingDebugSettings = true
                }) {
                  HStack {
                    Image(systemName: "key.fill")
                    Text("키체인 관리")
                    Spacer()
                    Image(systemName: "chevron.right")
                      .font(.caption)
                      .foregroundColor(.secondary)
                  }
                }
              }
            }
          }
          .navigationTitle("디버그")
        }
        .tabItem {
          Image(systemName: "hammer.fill")
          Text("디버그")
        }
        .sheet(isPresented: $showingDebugSettings) {
          DebugSettingsView()
        }
      #endif
    }
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}
