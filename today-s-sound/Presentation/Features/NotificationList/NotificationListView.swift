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
          VStack(alignment: .leading, spacing: 16) {
            ScreenMainTitle(text: "최근 알림", colorScheme: colorScheme)
              .padding(.horizontal, 20)

            content
              .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
              .padding(.bottom, 16)
          }
      }
    }
    .onAppear {
      viewModel.loadAlarms()
    }
  }

  @ViewBuilder
  private var content: some View {
      // 로딩
    if viewModel.isLoading && viewModel.alarms.isEmpty {
        Spacer()
        ProgressView("불러오는 중...")
          .progressViewStyle(CircularProgressViewStyle())
          .accessibilityLabel("알림 목록을 불러오는 중입니다")
          .accessibilityHint("잠시만 기다려주세요")
        Spacer()
    }
      // 에러
      else if let errorMessage = viewModel.errorMessage, viewModel.alarms.isEmpty {    Spacer()
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
    } // 알림 없음
      else if viewModel.alarms.isEmpty {
        Spacer()
        VStack(spacing: 16) {
          Text("새로운 알림이 없습니다")
            .font(.KoddiBold20)
            .foregroundColor(Color.secondaryText(colorScheme))
            .accessibilityLabel("새로운 알림이 없습니다")
        }
        Spacer()
    } else {
      ScrollView {
          LazyVStack(spacing: 12) {
            ForEach(viewModel.alarms) { alarm in
              AlertCardView(alarm: alarm, colorScheme: colorScheme)
                .onAppear {
                  viewModel.loadMoreIfNeeded(currentItem: alarm)
                }
            }

            if viewModel.isLoadingMore {
              ProgressView()
                .padding()
            }
          }
          .padding(.horizontal, 20)
          .padding(.bottom, 16)
        }
      }
    }
}

#if DEBUG
struct NotificationListView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      NotificationListView(viewModel: .previewData)
        .environment(\.colorScheme, .light)

      NotificationListView(viewModel: .previewEmpty)
        .environment(\.colorScheme, .light)

      NotificationListView(viewModel: .previewError)
        .environment(\.colorScheme, .light)
    }
  }
}

extension NotificationListViewModel {
  private static func sampleAlarms() -> [AlarmItem] {
    [
      AlarmItem(
        subscriptionId: 1,
        alias: "접근성 블로그",
        summaryContent: "애플이 새로운 보이스오버 기능을 발표했습니다.",
        timeAgo: "3분 전",
        isUrgent: false
      ),
      AlarmItem(
        subscriptionId: 2,
        alias: "오늘의 소리",
        summaryContent: "오늘의 소리에서 새로운 음성이 도착했습니다.",
        timeAgo: "10분 전",
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
