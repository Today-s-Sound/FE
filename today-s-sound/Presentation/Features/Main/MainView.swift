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
              .accessibilityHidden(true)   // 아이콘은 숨기고
            Text("홈")                    // 이름만 읽히게
          }
        }
        .tag(Tab.home)

      FeedView()
        .tabItem {
          VStack {
            Image(systemName: "text.bubble.fill")
              .accessibilityHidden(true)
            Text("피드")
          }
        }
        .tag(Tab.feed)

      NotificationListView()
        .tabItem {
          VStack {
            Image(systemName: "bell.fill")
              .accessibilityHidden(true)
            Text("알림")
          }
        }
        .tag(Tab.notifications)

      SubscriptionListView()
        .tabItem {
          VStack {
            Image(systemName: "books.vertical.fill")
              .accessibilityHidden(true)
            Text("구독")
          }
        }
        .tag(Tab.subscriptions)

      SettingsView()
        .tabItem {
          VStack {
            Image(systemName: "gearshape.fill")
              .accessibilityHidden(true)
            Text("설정")
          }
        }
        .tag(Tab.settings)
    }
    .tint(.primaryGreen)
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}
