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

          // 로딩 상태
          if viewModel.isLoading, viewModel.subscriptions.isEmpty {
            Spacer()
            ProgressView("불러오는 중...")
              .progressViewStyle(CircularProgressViewStyle())
            Spacer()
          }
          // 에러 메시지
          else if let errorMessage = viewModel.errorMessage {
            Spacer()
            VStack(spacing: 16) {
              Text("⚠️")
                .font(.system(size: 48))
              Text(errorMessage)
                .font(.system(size: 16))
                .foregroundColor(Color.secondaryText(colorScheme))
              Button("다시 시도") {
                viewModel.refresh()
              }
              .padding(.horizontal, 24)
              .padding(.vertical, 12)
              .background(Color.primaryGreen)
              .foregroundColor(.white)
              .cornerRadius(8)
            }
            Spacer()
          }
          // 구독 목록
          else {
            SubscriptionsListSection(
              subscriptions: viewModel.subscriptions,
              colorScheme: colorScheme,
              onLoadMore: { item in
                viewModel.loadMoreIfNeeded(currentItem: item)
              },
              onDelete: { item in
                viewModel.deleteSubscription(item)
              },
              isLoadingMore: viewModel.isLoadingMore
            )
          }

          AddSubscriptionButton(colorScheme: colorScheme) {
            showAddSubscription = true
          }
        }
      }
      .navigationBarHidden(true)
      .onAppear {
        // 처음 로드
        if viewModel.subscriptions.isEmpty {
          viewModel.loadSubscriptions()
        }
      }
      .refreshable {
        // Pull to refresh
        viewModel.refresh()
      }
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
