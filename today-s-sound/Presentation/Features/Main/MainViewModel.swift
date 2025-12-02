import Combine
import Foundation

class MainViewModel: ObservableObject {
  @Published var playbackRate: Double = 1.0
  @Published var currentCategoryName: String = "동국대학교 공지사항"
  @Published var recentAlerts: [Alert] = []
  @Published var homeFeedItems: [FeedItemResponse] = []
  @Published var isLoading: Bool = false
  @Published var errorMessage: String?

  private let apiService: APIService
  private var cancellables = Set<AnyCancellable>()

  init(apiService: APIService = APIService()) {
    self.apiService = apiService
    loadMockAlerts()
  }

  func increaseRate() {
    playbackRate = min(2.0, (playbackRate * 10 + 1).rounded() / 10)
  }

  func decreaseRate() {
    playbackRate = max(0.5, (playbackRate * 10 - 1).rounded() / 10)
  }

  func playAlert(_ alert: Alert) {
    SpeechService.shared.speak(text: alert.title)
  }

  /// 홈 피드 불러오기
  func loadHomeFeed() {
    guard !isLoading else { return }

    guard let userId = Keychain.getString(for: KeychainKey.userId),
          let deviceSecret = Keychain.getString(for: KeychainKey.deviceSecret)
    else {
      errorMessage = "사용자 정보가 없습니다"
      return
    }

    isLoading = true
    errorMessage = nil

    print("📡 홈 피드 요청")

    apiService.getHomeFeed(
      userId: userId,
      deviceSecret: deviceSecret
    )
    .receive(on: DispatchQueue.main)
    .sink(
      receiveCompletion: { [weak self] completion in
        guard let self else { return }
        isLoading = false

        switch completion {
        case .finished:
          break

        case let .failure(error):
          switch error {
          case let .serverError(statusCode):
            errorMessage = "서버 오류 (상태: \(statusCode))"

          case .decodingFailed:
            errorMessage = "응답 처리 실패"

          case let .requestFailed(requestError):
            errorMessage = "요청 실패: \(requestError.localizedDescription)"

          case .invalidURL:
            errorMessage = "잘못된 URL"

          case .unknown:
            errorMessage = "알 수 없는 오류"
          }

          print("❌ 홈 피드 조회 실패: \(errorMessage ?? "")")
        }
      },
      receiveValue: { [weak self] feedItems in
        guard let self else { return }
        homeFeedItems = feedItems
        
        // 홈 피드의 첫 번째 아이템이 있으면 카테고리 이름 업데이트
        if let firstItem = feedItems.first {
          currentCategoryName = firstItem.alias
        }
        
        print("✅ 홈 피드 조회 성공: \(feedItems.count)개")
      }
    )
    .store(in: &cancellables)
  }

  /// 홈 피드의 첫 번째 아이템 재생
  func playFirstFeedItem() {
    if let firstItem = homeFeedItems.first {
        let text = "\(firstItem.alias). \(firstItem.summaryContent)"
      SpeechService.shared.speak(text: text)
    }
  }

  private func loadMockAlerts() {
    recentAlerts = [
      Alert(id: UUID(), title: "일이삼사오육칠팔", content: "공지 내용 예시", date: Date().addingTimeInterval(-7200), isUrgent: true),
      Alert(id: UUID(), title: "잡코리아 채용 공고", content: "채용 소식", date: Date().addingTimeInterval(-10800), isUrgent: false)
    ]
  }
}
