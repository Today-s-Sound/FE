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
          Image(systemName: "play.house.fill")
          Text("홈")
        }
        .tag(Tab.home)
        .accessibilityLabel("홈 탭")

      FeedView()
        .tabItem {
          Image(systemName: "text.bubble.fill")
          Text("피드")
        }
        .tag(Tab.feed)
        .accessibilityLabel("피드 탭")

      NotificationListView()
        .tabItem {
          Image(systemName: "bell.fill")
          Text("알림")
        }
        .tag(Tab.notifications)
        .accessibilityLabel("알림 탭")

      SubscriptionListView()
        .tabItem {
          Image(systemName: "books.vertical.fill")
          Text("구독")
        }
        .tag(Tab.subscriptions)
        .accessibilityLabel("구독 탭")

      SettingsView()
        .tabItem {
          Image(systemName: "gearshape.fill")
          Text("설정")
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
