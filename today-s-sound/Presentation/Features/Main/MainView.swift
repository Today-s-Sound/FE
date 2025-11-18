import SwiftUI

struct MainView: View {
  private enum Tab: Hashable {
    case home
    case feed
    case notifications
    case subscriptions
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

      FeedView()
        .tabItem {
          Image(systemName: "text.rectangle")
          Text("피드")
        }
        .tag(Tab.feed)

      NotificationListView()
        .tabItem {
          Image(systemName: "bell.fill")
          Text("알림")
        }
        .tag(Tab.notifications)

      SubscriptionListView()
        .tabItem {
          Image(systemName: "books.vertical.fill")
          Text("구독")
        }
        .tag(Tab.subscriptions)

    }
    .tint(.primaryGreen)
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}
