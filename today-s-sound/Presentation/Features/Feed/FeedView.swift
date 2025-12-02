import SwiftUI

struct FeedView: View {
  @StateObject private var viewModel = FeedViewModel()
  @Environment(\.colorScheme) private var colorScheme

  /// 현재 선택된 필터 (기본값: "전체")
  @State private var selectedFilter: String = "전체"

  /// 필터 옵션 목록: ["전체", "교육부 보도자료", "서울시청 뉴스룸", "오늘의 소리 팀", ...]
  private var filterOptions: [String] {
    let sources = Set(viewModel.items.map(\.source))
    let sorted = Array(sources).sorted()
    return ["전체"] + sorted
  }

  /// 선택된 필터에 따라 걸러진 피드 아이템
  private var filteredItems: [FeedItem] {
    if selectedFilter == "전체" {
      viewModel.items
    } else {
      viewModel.items.filter { $0.source == selectedFilter }
    }
  }

  var body: some View {
    NavigationView {
      ZStack {
        Color.background(colorScheme)
          .ignoresSafeArea()

        content
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
      .navigationBarHidden(true)
      .onAppear {
        if viewModel.items.isEmpty {
          viewModel.loadFeeds()
        }
      }
    }
  }

  // MARK: - 상태별 컨텐츠

  @ViewBuilder
  private var content: some View {
    if viewModel.isLoading, viewModel.items.isEmpty {
      loadingState
    } else if let errorMessage = viewModel.errorMessage, viewModel.items.isEmpty {
      errorState(message: errorMessage)
    } else if viewModel.items.isEmpty {
      emptyState
    } else {
      feedList
    }
  }

  private var loadingState: some View {
    VStack {
      Spacer()
      ProgressView("피드를 불러오는 중...")
        .progressViewStyle(CircularProgressViewStyle())
        .accessibilityLabel("피드를 불러오는 중입니다")
        .accessibilityHint("잠시만 기다려주세요")
      Spacer()
    }
    .padding(.horizontal, 24)
  }

  private func errorState(message: String) -> some View {
    VStack(spacing: 16) {
      Spacer()
      Text(message)
        .font(.KoddiBold20)
        .foregroundColor(Color.secondaryText(colorScheme))
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)

      Button("다시 시도") {
        Task { await viewModel.refresh() }
      }
      .padding(.horizontal, 24)
      .padding(.vertical, 12)
      .font(.KoddiBold20)
      .foregroundColor(.white)
      .background(Color.primaryGreen)
      .cornerRadius(10)
      .accessibilityLabel("다시 시도 버튼")
      .accessibilityHint("탭하여 피드를 다시 불러옵니다")
      Spacer()
    }
    .padding(.horizontal, 24)
  }

  private var emptyState: some View {
    VStack {
      Spacer()
      Text("표시할 피드가 없습니다")
        .font(.KoddiBold20)
        .foregroundColor(Color.secondaryText(colorScheme))
        .multilineTextAlignment(.center)
        .accessibilityLabel("표시할 피드가 없습니다")
      Spacer()
    }
    .padding(.horizontal, 24)
  }

  // MARK: - 실제 피드 리스트

  private var feedList: some View {
    ScrollView {
      LazyVStack(spacing: 16) {
        // 상단 필터 바 (타이틀 없이, 항상 맨 위)
        filterBar
          .padding(.horizontal, 20)
          .padding(.top, 12)
          .padding(.bottom, 4)

        // 필터된 카드 리스트
        ForEach(filteredItems) { item in
          FeedCard(item: item, colorScheme: colorScheme)
            .padding(.horizontal, 16)
            .onAppear {
              viewModel.loadMoreIfNeeded(currentItem: item)
            }
        }

        // 더 불러오기 로딩 인디케이터
        if viewModel.isLoadingMore {
          HStack {
            Spacer()
            ProgressView()
              .padding()
              .accessibilityLabel("추가 피드를 불러오는 중입니다")
            Spacer()
          }
        }
      }
      .padding(.bottom, 24)
    }
    .refreshable {
      await viewModel.refresh()
      // 새로고침 후 필터 옵션이 바뀔 수 있으니 선택값 보정
      if !filterOptions.contains(selectedFilter) {
        selectedFilter = "전체"
      }
    }
  }

  /// 상단 필터 버튼 바 (단일 선택)
  private var filterBar: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(Array(filterOptions.enumerated()), id: \.offset) { _, option in
          let isSelected = (option == selectedFilter)

          Button {
            selectedFilter = option
          } label: {
            Text(option)
              .font(.KoddiBold20)
              .padding(.horizontal, 14)
              .padding(.vertical, 8)
              .background(
                Capsule()
                  .fill(
                    isSelected
                      ? Color.primaryGreen
                      : Color.secondaryBackground(colorScheme)
                  )
              )
              .foregroundColor(
                isSelected
                  ? Color.white
                  : Color.text(colorScheme)
              )
              .overlay(
                Capsule()
                  .stroke(
                    isSelected
                      ? Color.primaryGreen
                      : Color.border(colorScheme),
                    lineWidth: 1
                  )
              )
          }
          .buttonStyle(.plain)
          .accessibilityLabel("필터 탭, \(option) 피드 보기")
          .accessibilityHint("이 버튼을 선택하면 \(option) 피드만 볼 수 있습니다")
        }
      }
      .padding(.vertical, 4)
    }
  }
}

// MARK: - 카드 뷰

private struct FeedCard: View {
  let item: FeedItem
  let colorScheme: ColorScheme

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // 페이지 이름 (작은 회색 텍스트)
      Text(item.source)
        .font(.KoddiRegular16)
        .foregroundColor(Color.secondaryText(colorScheme))

      // 제목 (큰 볼드 텍스트, 두 줄 가능)
      Text(item.alias)
        .font(.KoddiBold28)
        .foregroundColor(Color.text(colorScheme))
        .multilineTextAlignment(.leading)
        .lineLimit(2)

      // 내용 (중간 크기 텍스트, 여러 줄 가능)
      Text(item.summary)
        .font(.KoddiRegular20)
        .foregroundColor(Color.text(colorScheme))
        .multilineTextAlignment(.leading)
        .lineLimit(nil)

      // 시간 (작은 초록색 텍스트)
      Text(item.timeAgo)
        .font(.KoddiRegular16)
        .foregroundColor(.primaryGreen)
    }
    .padding(20)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.secondaryBackground(colorScheme))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 16)
        .stroke(Color.border(colorScheme), lineWidth: 1)
    )
    .accessibilityElement(children: .combine)
    .accessibilityLabel(
      "\(item.source) 새 글, \(item.alias), \(item.summary), \(item.timeAgo)"
    )
  }
}

// MARK: - 프리뷰

struct FeedView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      FeedView()
        .environment(\.colorScheme, .light)

      FeedView()
        .environment(\.colorScheme, .dark)
    }
  }
}
