import Foundation

@MainActor
final class FeedViewModel: ObservableObject {
  @Published var items: [FeedItem] = FeedSampleData.items
  @Published var isLoading: Bool = false
  @Published var errorMessage: String?

  func refresh() async {
    isLoading = true
    errorMessage = nil

    do {
      try await Task.sleep(nanoseconds: 800_000_000)
      items = FeedSampleData.items.shuffled()
      isLoading = false
    } catch {
      isLoading = false
      errorMessage = "피드를 새로고침하지 못했습니다"
    }
  }
}

