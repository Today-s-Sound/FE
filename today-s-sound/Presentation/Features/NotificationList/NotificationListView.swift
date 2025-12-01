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

        VStack(alignment: .leading, spacing: 4) {
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
    if viewModel.isLoading, viewModel.alarms.isEmpty {
      Spacer()
      ProgressView("불러오는 중...")
        .progressViewStyle(CircularProgressViewStyle())
        .accessibilityLabel("알림 목록을 불러오는 중입니다")
        .accessibilityHint("잠시만 기다려주세요")
      Spacer()
    }
    // 에러
    else if let errorMessage = viewModel.errorMessage, viewModel.alarms.isEmpty {
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
    // 알림 없음
    else if viewModel.alarms.isEmpty {
      Spacer()
      VStack(spacing: 16) {
        Text("새로운 알림이 없습니다")
          .font(.KoddiBold20)
          .foregroundColor(Color.secondaryText(colorScheme))
          .accessibilityLabel("새로운 알림이 없습니다")
      }
      Spacer()
    }
    // 알림 목록
    else {
      List {
        ForEach(viewModel.alarms) { alarm in
          AlertCardView(alarm: alarm, colorScheme: colorScheme)
            .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 12, trailing: 20))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .onAppear {
              viewModel.loadMoreIfNeeded(currentItem: alarm)
            }
            .swipeActions {
              Button(role: .destructive) {
                viewModel.delete(alarm: alarm)
              } label: {
                Label("삭제", systemImage: "trash")
              }
              .accessibilityLabel("알림 삭제")
              .accessibilityHint("이 알림을 목록에서 삭제합니다")
            }
        }

        if viewModel.isLoadingMore {
          HStack {
            Spacer()
            ProgressView()
            Spacer()
          }
          .listRowSeparator(.hidden)
          .listRowBackground(Color.clear)
        }
      }
      .listStyle(.plain)
      .scrollContentBackground(.hidden)
    }
  }
}

#if DEBUG
  struct NotificationListView_Previews: PreviewProvider {
    static var previews: some View {
      Group {
        // 데이터 있는 상태 - 라이트 모드
        NotificationListView(viewModel: .previewData)
          .environment(\.colorScheme, .light)
          .previewDisplayName("알림 목록 - Light")

        // 데이터 있는 상태 - 다크 모드
        NotificationListView(viewModel: .previewData)
          .environment(\.colorScheme, .dark)
          .previewDisplayName("알림 목록 - Dark")

        // 빈 상태
        NotificationListView(viewModel: .previewEmpty)
          .environment(\.colorScheme, .light)
          .previewDisplayName("알림 없음")

        // 에러 상태
        NotificationListView(viewModel: .previewError)
          .environment(\.colorScheme, .light)
          .previewDisplayName("에러 상태")
      }
    }
  }

  extension NotificationListViewModel {
    private static func sampleAlarms() -> [AlarmItem] {
      [
        AlarmItem(
          subscriptionId: 1,
          alias: "동국대 SW 융합교육원",
          summaryContent: "동국대학교 SW 융합교육원에서 신입생 및 재학생을 위한 SW 교육 프로그램 공지가 등록되었습니다. 신청 마감 기한을 꼭 확인해주세요.",
          timeAgo: "5분 전",
          isUrgent: true
        ),
        AlarmItem(
          subscriptionId: 2,
          alias: "오늘의 소리 팀 공지",
          summaryContent: "오늘의 소리 앱이 업데이트되었습니다. 보이스오버 지원이 개선되고, 일부 버그가 수정되었습니다.",
          timeAgo: "12분 전",
          isUrgent: false
        ),
        AlarmItem(
          subscriptionId: 3,
          alias: "장학 공지",
          summaryContent: "2025학년도 1학기 장학금 신청 안내입니다. 신청 자격과 필요 서류를 꼭 확인한 뒤 기한 내 제출해주세요.",
          timeAgo: "30분 전",
          isUrgent: true
        ),
        AlarmItem(
          subscriptionId: 4,
          alias: "동국대 일정 안내",
          summaryContent: "이번 주 캠퍼스 주요 일정과 행사를 정리하여 안내드립니다. 관심 있는 프로그램에 미리 신청해보세요.",
          timeAgo: "1시간 전",
          isUrgent: false
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
