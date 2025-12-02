import SwiftUI

struct MainView: View {
  private enum Tab: Hashable {
    case home
    case feed
    case notifications
    case subscriptions
    case settings
  }

  @State private var selectedTab: Tab = .home

  var body: some View {
    TabView(selection: $selectedTab) {
      HomeView()
        .tabItem {
          VStack {
            Image(systemName: "play.house.fill")
              .accessibilityHidden(true) // 아이콘은 읽지 않도록
            Text("홈")
          }
        }
        .tag(Tab.home)
        .accessibilityLabel("홈 탭")

      FeedView()
        .tabItem {
          VStack {
            Image(systemName: "text.bubble.fill")
              .accessibilityHidden(true)
            Text("피드")
          }
        }
        .tag(Tab.feed)
        .accessibilityLabel("피드 탭")

      NotificationListView()
        .tabItem {
          VStack {
            Image(systemName: "bell.fill")
              .accessibilityHidden(true)
            Text("알림")
          }
        }
        .tag(Tab.notifications)
        .accessibilityLabel("알림 탭")

      SubscriptionListView()
        .tabItem {
          VStack {
            Image(systemName: "books.vertical.fill")
              .accessibilityHidden(true)
            Text("구독")
          }
        }
        .tag(Tab.subscriptions)
        .accessibilityLabel("구독 탭")

      SettingsView()
        .tabItem {
          VStack {
            Image(systemName: "gearshape.fill")
              .accessibilityHidden(true)
            Text("설정")
          }
        }
        .tag(Tab.settings)
        .accessibilityLabel("설정 탭")
    }
    .tint(.primaryGreen)
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}
