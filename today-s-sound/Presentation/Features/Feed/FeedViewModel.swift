import Foundation

@MainActor
final class FeedViewModel: ObservableObject {
  @Published var items: [FeedItem] = FeedSampleData.items
  @Published var isLoading: Bool = false
  @Published var errorMessage: String?

  /// 새로고침 (데모에서는 단순 셔플)
  func refresh() async {
    isLoading = true
    errorMessage = nil

    do {
      // 실제 API 연동 전까지는 약간의 딜레이를 주고 셔플만 함
      try await Task.sleep(nanoseconds: 800_000_000)
      items = FeedSampleData.items.shuffled()
      isLoading = false
    } catch {
      isLoading = false
      errorMessage = "피드를 새로고침하지 못했습니다"
    }
  }
}
