import SwiftUI

struct SubscriptionListView: View {
  @StateObject private var viewModel = SubscriptionListViewModel()
  @Environment(\.colorScheme) var colorScheme
  @State private var showAddSubscription = false

  var body: some View {
    NavigationView {
      ZStack {
        Color.background(colorScheme)
          .ignoresSafeArea()

        VStack(alignment: .leading, spacing: 12) {
          Spacer()
          ScreenMainTitle(text: "구독 설정", colorScheme: colorScheme)
          ScreenSubTitle(text: "구독 중인 페이지", colorScheme: colorScheme)

          SubscriptionsListSection(
            subscriptions: viewModel.subscriptions,
            colorScheme: colorScheme
          )

          AddSubscriptionButton(colorScheme: colorScheme) {
            showAddSubscription = true
          }
        }
      }
      .navigationBarHidden(true)
    }
    .sheet(isPresented: $showAddSubscription) {
      AddSubscriptionView()
    }
  }
}

struct SubscriptionListView_Previews: PreviewProvider {
  static var previews: some View {
    SubscriptionListView()
  }
}
