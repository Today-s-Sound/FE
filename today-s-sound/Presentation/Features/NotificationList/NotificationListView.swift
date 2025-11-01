import SwiftUI

struct NotificationListView: View {
  @StateObject private var viewModel = NotificationListViewModel()
  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    NavigationView {
      ZStack {
        Color.background(colorScheme)
          .ignoresSafeArea()

        VStack(spacing: 0) {
          Spacer()
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
              Text("⚠️")
                .font(.system(size: 48))
                .accessibilityHidden(true) // 이모지는 숨김, 텍스트로 전달

              Text(errorMessage)
                .font(.system(size: 16))
                .foregroundColor(Color.secondaryText(colorScheme))
                .accessibilityLabel("오류: \(errorMessage)")

              Button("다시 시도") {
                viewModel.refresh()
              }
              .padding(.horizontal, 24)
              .padding(.vertical, 12)
              .background(Color.primaryGreen)
              .foregroundColor(.white)
              .cornerRadius(8)
              .accessibilityLabel("다시 시도 버튼")
              .accessibilityHint("이중탭하여 알림 목록을 다시 불러옵니다")
            }
            Spacer()
          }
          // 빈 상태
          else if viewModel.alarms.isEmpty {
            Spacer()
            VStack(spacing: 16) {
              Text("📭")
                .font(.system(size: 48))
                .accessibilityHidden(true) // 이모지는 숨김

              Text("최근 알림이 없습니다")
                .font(.system(size: 16))
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
        if viewModel.alarms.isEmpty {
          viewModel.loadAlarms()
        }
      }
    }
  }
}

struct NotificationListView_Previews: PreviewProvider {
  static var previews: some View {
    NotificationListView()
  }
}
