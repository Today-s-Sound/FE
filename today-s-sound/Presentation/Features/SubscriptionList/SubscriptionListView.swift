import SwiftUI

struct SubscriptionListView: View {
  @EnvironmentObject var session: SessionStore // ✅ SessionStore 주입 받기
  @StateObject private var viewModel = SubscriptionListViewModel()
  @Environment(\.colorScheme) var colorScheme
  @State private var showAddSubscription = false

  var body: some View {
    NavigationView {
      ZStack {
        Color.background(colorScheme).ignoresSafeArea()

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
      // ✅ 세션을 전달해서 AddSubscriptionViewModel이 API를 쓸 수 있게 함
      AddSubscriptionView(session: session)
        .environmentObject(session) // 선택적이지만 유지해두면 하위에서도 접근 가능
    }
  }
}

struct SubscriptionListView_Previews: PreviewProvider {
  static var previews: some View {
    SubscriptionListView()
      .environmentObject(SessionStore()) // ✅ 프리뷰용 더미 세션 주입
  }
}
