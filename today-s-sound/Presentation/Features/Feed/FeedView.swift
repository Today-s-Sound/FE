import SwiftUI

struct FeedView: View {
  @StateObject private var viewModel = FeedViewModel()
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    NavigationView {
      ZStack {
        Color.background(colorScheme)
          .ignoresSafeArea()

        VStack(spacing: 0) {
          ScreenMainTitle(text: "피드", colorScheme: colorScheme)
          content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
      }
      .navigationBarHidden(true)
    }
  }

  @ViewBuilder
  private var content: some View {
    if viewModel.isLoading, viewModel.items.isEmpty {
      loadingState
    } else if let errorMessage = viewModel.errorMessage {
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
  }

  private func errorState(message: String) -> some View {
    VStack(spacing: 16) {
      Spacer()
      Text(message)
        .font(.KoddiBold20)
        .foregroundColor(Color.secondaryText(colorScheme))
        .accessibilityLabel("오류: \(message)")
        .padding(.bottom, 8)

      Button("다시 시도") {
        Task { await viewModel.refresh() }
      }
      .padding(.horizontal, 24)
      .padding(.vertical, 12)
      .font(.KoddiBold20)
      .foregroundColor(.white)
      .background(Color.primaryGreen)
      .cornerRadius(10)
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
        .accessibilityLabel("표시할 피드가 없습니다")
      Spacer()
    }
  }

  private var feedList: some View {
    ScrollView {
      LazyVStack(spacing: 16) {
        ForEach(viewModel.items) { item in
          FeedCard(item: item, colorScheme: colorScheme)
        }
      }
      .padding(.horizontal, 20)
      .padding(.bottom, 24)
      .padding(.top, 8)
    }
    .refreshable {
      await viewModel.refresh()
    }
  }
}

private struct FeedCard: View {
  let item: FeedItem
  let colorScheme: ColorScheme

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(item.source.uppercased())
        .font(.system(size: 13, weight: .semibold))
        .foregroundColor(Color.secondaryText(colorScheme))

      Text(item.title)
        .font(.KoddiBold28)
        .foregroundColor(Color.text(colorScheme))
        .multilineTextAlignment(.leading)

      Text(item.summary)
        .font(.KoddiRegular16)
        .foregroundColor(Color.secondaryText(colorScheme))
        .multilineTextAlignment(.leading)

      Text(item.relativeTimeText)
        .font(.system(size: 14, weight: .medium))
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
    .accessibilityLabel("\(item.source) 새 글, \(item.title), \(item.summary), \(item.relativeTimeText)")
  }
}

struct FeedView_Previews: PreviewProvider {
  static var previews: some View {
    FeedView()
  }
}
