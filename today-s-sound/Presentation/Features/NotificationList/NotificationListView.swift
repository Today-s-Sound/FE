import SwiftUI

struct NotificationListView: View {
  @StateObject private var viewModel: NotificationListViewModel
  @Environment(\.colorScheme) var colorScheme

  init(viewModel: NotificationListViewModel = NotificationListViewModel()) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }

  var body: some View {
    NavigationView {
      ZStack {
        Color.background(colorScheme)
          .ignoresSafeArea()

        VStack(spacing: 0) {
          ScreenMainTitle(text: "최근 알림", colorScheme: colorScheme)

          // 로딩 상태
          if viewModel.isLoading, viewModel.alarms.isEmpty {
            Spacer()
            ProgressView("불러오는 중...")
              .progressViewStyle(CircularProgressViewStyle())
              .accessibilityLabel("알림 목록을 불러오는 중입니다")
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
              .accessibilityHint("탭하여 알림 목록을 다시 불러옵니다")
            }
            Spacer()
          }
            
          // 빈 상태
          else if viewModel.alarms.isEmpty {
            Spacer()
            VStack(spacing: 16) {
              Text("최근 알림이 없습니다")
                .font(.KoddiBold20)
                .foregroundColor(Color.secondaryText(colorScheme))
                .accessibilityLabel("최근 알림이 없습니다")
            }
            Spacer()
          }
            
          // 알림 목록
          else {
            ScrollView {
              VStack(spacing: 16) {
                ForEach(Array(viewModel.alarms.enumerated()), id: \.element.id) { index, alarm in
                  AlertCardView(alarm: alarm, colorScheme: colorScheme)
                    .accessibilityElement(children: .ignore) // 개별 카드 내부 접근성은 카드에서 처리
                    .accessibilityLabel("알림 \(index + 1), \(viewModel.alarms.count)개 중")
                    .onAppear {
                      // 마지막에서 3번째 아이템이 보일 때만 트리거
                      if let lastIndex = viewModel.alarms.indices.last,
                         let currentIndex = viewModel.alarms.firstIndex(where: { $0.id == alarm.id }),
                         currentIndex >= lastIndex - 2
                      {
                        viewModel.loadMoreIfNeeded(currentItem: alarm)
                      }
                    }
                }

                // 더 불러오는 중 인디케이터
                if viewModel.isLoadingMore {
                  HStack {
                    Spacer()
                    ProgressView()
                      .padding()
                      .accessibilityLabel("추가 알림을 불러오는 중입니다")
                    Spacer()
                  }
                }
              }
              .padding(.horizontal, 16)
              .padding(.top, 8)
            }
            .refreshable {
              viewModel.refresh()
            }
            .accessibilityLabel("알림 목록")
            .accessibilityHint("총 \(viewModel.alarms.count)개의 알림이 있습니다. 아래로 당겨서 새로고침할 수 있습니다")
          }
        }
      }
      .navigationBarHidden(true)
      .onAppear {
        // 처음 로드
        if viewModel.alarms.isEmpty, !viewModel.disableAutoLoad {
          viewModel.loadAlarms()
        }
      }
    }
  }
}

struct NotificationListView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      NotificationListView(viewModel: .previewLoading)
        .previewDisplayName("Loading")

      NotificationListView(viewModel: .previewError)
        .previewDisplayName("Error")

      NotificationListView(viewModel: .previewEmpty)
        .previewDisplayName("Empty")

      NotificationListView(viewModel: .previewData)
        .previewDisplayName("With Data")
    }
  }
}

#if DEBUG
extension NotificationListViewModel {
  private static func sampleAlarms() -> [AlarmItem] {
    [
      AlarmItem(
        alias: "접근성 블로그",
        timeAgo: "3분 전",
        summaries: [
          SummaryItem(id: 1, summary: "애플이 새로운 보이스오버 기능을 발표했습니다.", updatedAt: "2024-12-19T09:00:00Z"),
          SummaryItem(id: 2, summary: "iOS 18에서 접근성 옵션이 대폭 개선됩니다.", updatedAt: "2024-12-19T09:05:00Z")
        ],
        isUrgent: false
      ),
      AlarmItem(
        alias: "오늘의 소리 알림",
        timeAgo: "10분 전",
        summaries: [
          SummaryItem(id: 3, summary: "오늘의 소리에서 새 음성이 도착했습니다.", updatedAt: "2024-12-19T08:50:00Z")
        ],
        isUrgent: true
      )
    ]
  }

  static var previewLoading: NotificationListViewModel {
    let vm = NotificationListViewModel(apiService: APIService())
    vm.isLoading = true
    vm.alarms = []
    vm.errorMessage = nil
    vm.disableAutoLoad = true
    return vm
  }

  static var previewError: NotificationListViewModel {
    let vm = NotificationListViewModel(apiService: APIService())
    vm.errorMessage = "서버와 연결할 수 없습니다"
    vm.alarms = []
    vm.isLoading = false
    vm.disableAutoLoad = true
    return vm
  }

  static var previewEmpty: NotificationListViewModel {
    let vm = NotificationListViewModel(apiService: APIService())
    vm.alarms = []
    vm.isLoading = false
    vm.errorMessage = nil
    vm.disableAutoLoad = true
    return vm
  }

  static var previewData: NotificationListViewModel {
    let vm = NotificationListViewModel(apiService: APIService())
    vm.alarms = sampleAlarms()
    vm.isLoading = false
    vm.errorMessage = nil
    vm.disableAutoLoad = true
    return vm
  }
}
#endif
