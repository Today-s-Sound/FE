import SwiftUI

struct SubscriptionListView: View {
  @StateObject private var viewModel: SubscriptionListViewModel
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.dismiss) var dismiss
  @State private var showAddSubscription = false

  init(viewModel: SubscriptionListViewModel = SubscriptionListViewModel()) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }

  var body: some View {
    ZStack {
      Color.background(colorScheme)
        .ignoresSafeArea()

      VStack(spacing: 12) {
        ScreenMainTitle(text: "구독 관리", colorScheme: colorScheme)
        ScreenSubTitle(text: "구독 중인 페이지", colorScheme: colorScheme)
          .padding(.top, 16)

          // 로딩 상태
          if viewModel.isLoading, viewModel.subscriptions.isEmpty {
            Spacer()
            ProgressView("불러오는 중...")
              .progressViewStyle(CircularProgressViewStyle())
              .accessibilityLabel("구독 목록을 불러오는 중입니다")
              .accessibilityHint("잠시만 기다려주세요")
            Spacer()
          }

          // 에러 메시지
          else if let errorMessage = viewModel.errorMessage {
            Spacer()
            VStack(spacing: 16) {
              Text(errorMessage)
                .font(.KoddiBold20)
                .foregroundColor(Color.secondaryText(colorScheme))
                .accessibilityLabel("오류: \(errorMessage)")
                .padding(.bottom)

              Button("다시 시도") {
                viewModel.refresh()
              }
              .padding(.horizontal, 24)
              .padding(.vertical, 12)
              .font(.KoddiBold20)
              .foregroundColor(Color.white)
              .background(Color.primaryGreen)
              .cornerRadius(8)
              .accessibilityLabel("다시 시도 버튼")
              .accessibilityHint("탭하여 구독 목록을 다시 불러옵니다")
            }
            Spacer()
          }
          // 빈 상태
          else if viewModel.subscriptions.isEmpty {
            Spacer()
            VStack(spacing: 16) {
              Text("구독 중인 페이지가 없습니다")
                .font(.KoddiBold20)
                .foregroundColor(Color.secondaryText(colorScheme))
                .accessibilityLabel("구독 중인 페이지가 없습니다")
            }
            Spacer()
          }

          // 데이터 있을 때(main)
          else {
            List {
              ForEach(viewModel.subscriptions) { subscription in
                SubscriptionCardView(
                  subscription: subscription,
                  colorScheme: colorScheme,
                  onToggleAlarm: { sub in
                    if sub.isUrgent {
                      viewModel.blockAlarm(sub)
                    } else {
                      viewModel.unblockAlarm(sub)
                    }
                  }
                )
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                  Button(role: .destructive) {
                    viewModel.deleteSubscription(subscription)
                  } label: {
                    Label("삭제", systemImage: "trash")
                  }
                  .accessibilityLabel("구독 삭제")
                  .accessibilityHint("이 구독을 목록에서 삭제합니다")
                }
                .onAppear {
                  if let lastIndex = viewModel.subscriptions.indices.last,
                     let currentIndex = viewModel.subscriptions.firstIndex(where: { $0.id == subscription.id }),
                     currentIndex >= lastIndex - 4
                  {
                    viewModel.loadMoreIfNeeded(currentItem: subscription)
                  }
                }
              }

              if viewModel.isLoadingMore {
                HStack {
                  Spacer()
                  ProgressView()
                    .padding()
                    .accessibilityLabel("추가 구독을 불러오는 중입니다")
                  Spacer()
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
              }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
          }
          AddSubscriptionButton(
            title: "새 웹페이지 추가",
            colorScheme: colorScheme,
            isEnabled: true
          ) {
            showAddSubscription = true
          }
          .padding(.horizontal, 20)
          .padding(.bottom, 16)
          .padding(.top, 12)
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarBackButtonHidden(true)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "chevron.left")
              .font(.KoddiBold20)
              .foregroundColor(Color.text(colorScheme))
          }
          .accessibilityLabel("뒤로 가기")
          .accessibilityHint("관리 페이지로 돌아갑니다")
        }
      }
      .onAppear {
        // 처음 로드
        if viewModel.subscriptions.isEmpty, !viewModel.disableAutoLoad {
          viewModel.loadSubscriptions()
        }
      }
      .refreshable {
        // Pull to refresh
        viewModel.refresh()
      }
      .sheet(isPresented: $showAddSubscription) {
        AddSubscriptionView()
      }
    }
  }

struct SubscriptionListView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      SubscriptionListView(viewModel: .previewLoading)
        .previewDisplayName("Loading")

      SubscriptionListView(viewModel: .previewError)
        .previewDisplayName("Error")

      SubscriptionListView(viewModel: .previewEmpty)
        .previewDisplayName("Empty")

      SubscriptionListView(viewModel: .previewData)
        .previewDisplayName("With Data")
    }
  }
}
