import SwiftUI
import UIKit

struct NotificationListView: View {
  @StateObject private var viewModel: NotificationListViewModel
  @EnvironmentObject var appTheme: AppThemeManager

  init(viewModel: NotificationListViewModel = NotificationListViewModel()) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }

  var body: some View {
    NavigationView {
      ZStack {
        Color.background(appTheme.theme)
          .ignoresSafeArea()

        VStack(alignment: .leading, spacing: 4) {
          ScreenMainTitle(text: "최근 알림", theme: appTheme.theme)
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
    if viewModel.isLoading, viewModel.alarms.isEmpty {
      Spacer()
      ProgressView("불러오는 중...")
        .progressViewStyle(CircularProgressViewStyle())
        .accessibilityLabel("알림 목록을 불러오는 중입니다")
        .accessibilityHint("잠시만 기다려주세요")
      Spacer()
    } else if let errorMessage = viewModel.errorMessage, viewModel.alarms.isEmpty {
      Spacer()
      VStack(spacing: 16) {
        Text(errorMessage)
          .font(.KoddiBold20)
          .foregroundColor(Color.secondaryText(appTheme.theme))
          .multilineTextAlignment(.center)
          .padding(.horizontal, 24)
          .accessibilityLabel("오류: \(errorMessage)")

        Button("다시 시도") {
          viewModel.refresh()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .font(.KoddiBold20)
        .foregroundColor(Color.white)
        .background(Color.primaryGreen)
        .cornerRadius(8)
        .accessibilityLabel("다시 시도")
        .accessibilityHint("탭하여 알림 목록을 다시 불러옵니다")
      }
      Spacer()
    } else if viewModel.alarms.isEmpty {
      Spacer()
      VStack(spacing: 0) {
        Text("새로운 알림이 없습니다")
          .font(.KoddiBold20)
          .foregroundColor(Color.secondaryText(appTheme.theme))
          .accessibilityLabel("새로운 알림이 없습니다")
      }
      .padding(.top, 28)
      Spacer()
    } else {
      List {
        ForEach(viewModel.alarms) { alarm in
          row(for: alarm)
            .onAppear {
              viewModel.loadMoreIfNeeded(currentItem: alarm)
            }
        }

        if viewModel.isLoadingMore {
          HStack {
            Spacer()
            ProgressView()
              .accessibilityLabel("추가 알림을 불러오는 중입니다")
            Spacer()
          }
          .listRowSeparator(.hidden)
          .listRowBackground(Color.clear)
        }
      }
      .listStyle(.plain)
      .scrollContentBackground(.hidden)
      .refreshable {
        viewModel.refresh()
      }
    }
  }

  @ViewBuilder
  private func row(for alarm: AlarmItem) -> some View {
    // 공통 카드 스타일
    let card = AlertCardView(
      alarm: alarm,
      theme: appTheme.theme,
      onDelete: { viewModel.delete(alarm: $0) } // ✅ VoiceOver 사용자 삭제 버튼 로직
    )
    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 12, trailing: 20))
    .listRowSeparator(.hidden)
    .listRowBackground(Color.clear)

    // ✅ VoiceOver가 켜져 있으면 swipeActions 제거 (불필요한 "추가 동작..." 안내 방지)
    if UIAccessibility.isVoiceOverRunning {
      card
    } else {
      card
        .swipeActions {
          Button(role: .destructive) {
            viewModel.delete(alarm: alarm)
          } label: {
            Label("삭제", systemImage: "trash")
          }
          .tint(.red) // ✅ 스와이프 삭제 배경 빨간색 통일
          .accessibilityLabel("삭제")
          .accessibilityHint("이 알림을 목록에서 삭제합니다")
        }
    }
  }
}

#if DEBUG
  struct NotificationListView_Previews: PreviewProvider {
    static var previews: some View {
      Group {
        NotificationListView(viewModel: .previewData)
          .environmentObject(AppThemeManager())
          .previewDisplayName("알림 목록 - Normal")

        NotificationListView(viewModel: .previewEmpty)
          .environmentObject(AppThemeManager())
          .previewDisplayName("알림 없음")

        NotificationListView(viewModel: .previewError)
          .environmentObject(AppThemeManager())
          .previewDisplayName("에러 상태")
      }
    }
  }

  extension NotificationListViewModel {
    private static func sampleAlarms() -> [AlarmItem] {
      [
        AlarmItem(
          subscriptionId: 1,
          summaryId: 101,
          alias: "동국대 SW 융합교육원",
          summaryContent: "동국대학교 SW 융합교육원에서 신입생 및 재학생을 위한 SW 교육 프로그램 공지가 등록되었습니다. 신청 마감 기한을 꼭 확인해주세요.",
          postUrl: "https://example.com/post/101",
          timeAgo: "5분 전",
          isKeywordMatched: true
        ),
        AlarmItem(
          subscriptionId: 2,
          summaryId: 102,
          alias: "오늘의 소리 팀 공지",
          summaryContent: "오늘의 소리 앱이 업데이트되었습니다. 보이스오버 지원이 개선되고, 일부 버그가 수정되었습니다.",
          postUrl: "https://example.com/post/102",
          timeAgo: "12분 전",
          isKeywordMatched: false
        ),
        AlarmItem(
          subscriptionId: 3,
          summaryId: 103,
          alias: "장학 공지",
          summaryContent: "2025학년도 1학기 장학금 신청 안내입니다. 신청 자격과 필요 서류를 꼭 확인한 뒤 기한 내 제출해주세요.",
          postUrl: "https://example.com/post/103",
          timeAgo: "30분 전",
          isKeywordMatched: true
        ),
        AlarmItem(
          subscriptionId: 4,
          summaryId: 104,
          alias: "동국대 일정 안내",
          summaryContent: "이번 주 캠퍼스 주요 일정과 행사를 정리하여 안내드립니다. 관심 있는 프로그램에 미리 신청해보세요.",
          postUrl: "https://example.com/post/104",
          timeAgo: "1시간 전",
          isKeywordMatched: false
        )
      ]
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
