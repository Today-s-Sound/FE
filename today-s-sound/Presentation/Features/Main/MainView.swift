
import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()

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
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
