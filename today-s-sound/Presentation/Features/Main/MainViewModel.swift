import Combine
import Foundation

class MainViewModel: ObservableObject {
  @Published var playbackRate: Double = 1.0
  @Published var currentCategoryName: String = ""
  @Published var recentAlerts: [Alert] = []
  @Published var homeFeedItems: [HomeFeedItemResponse] = []
  @Published var isLoading: Bool = false
  @Published var errorMessage: String?

  private let apiService: APIService
  private var cancellables = Set<AnyCancellable>()

  // 순차 재생을 위한 큐
  private var playbackQueue: [(category: String, items: [HomeFeedItemResponse])] = []
  private var currentGroupIndex: Int = 0
  private var currentItemIndex: Int = 0
  private var speechCancellable: AnyCancellable?

  init(apiService: APIService = APIService()) {
    self.apiService = apiService

    // UserDefaults에서 저장된 재생 속도 불러오기
    let savedRate = UserDefaults.standard.double(forKey: "playbackRate")
    if savedRate > 0 {
      playbackRate = savedRate
    }

    setupSpeechListener()
    setupPlaybackRateListener()
  }

  private func setupSpeechListener() {
    // SpeechService의 재생 완료 이벤트 구독
    speechCancellable = SpeechService.shared.didFinishSpeaking
      .sink { [weak self] _ in
        self?.playNextItem()
      }
  }

  private func setupPlaybackRateListener() {
    // PlaybackSettingsView에서 재생 속도 변경 시 동기화
    NotificationCenter.default.publisher(for: Notification.Name("PlaybackRateChanged"))
      .compactMap { $0.userInfo?["rate"] as? Double }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] newRate in
        self?.playbackRate = newRate
        print("🎚️ 재생 속도 변경됨: \(newRate)x")
      }
      .store(in: &cancellables)
  }

  func increaseRate() {
    playbackRate = min(2.0, (playbackRate * 10 + 1).rounded() / 10)
  }

  func decreaseRate() {
    playbackRate = max(0.5, (playbackRate * 10 - 1).rounded() / 10)
  }

  func playAlert(_ alert: Alert) {
    SpeechService.shared.speak(text: alert.title, rate: Float(playbackRate))
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
      receiveValue: { [weak self] response in
        guard let self else { return }
        let feedItems = response.items
        homeFeedItems = feedItems

        // 홈 피드의 첫 번째 아이템이 있으면 카테고리 이름 업데이트
        if let firstItem = feedItems.first {
          currentCategoryName = firstItem.alias
        }

        print("✅ 홈 피드 조회 성공: \(feedItems.count)개")

        // 그룹화된 결과 출력 (디버깅용)
        let grouped = Dictionary(grouping: feedItems) { $0.alias }
        for (alias, items) in grouped {
          print("  📁 \(alias): \(items.count)개")
        }
      }
    )
    .store(in: &cancellables)
  }

  /// alias로 피드를 그룹화
  private func groupFeedsByAlias(_ feeds: [HomeFeedItemResponse]) -> [(category: String, items: [HomeFeedItemResponse])] {
    let grouped = Dictionary(grouping: feeds) { $0.alias }
    return grouped.map { (category: $0.key, items: $0.value) }
      .sorted { $0.category < $1.category } // 정렬 (선택사항)
  }

  /// 홈 피드 재생 시작 (그룹별로 순차 재생)
  func playFirstFeedItem() {
    guard !homeFeedItems.isEmpty else { return }

    // 기존 재생 중이면 중단
    if SpeechService.shared.isSpeaking {
      SpeechService.shared.stop()
    }

    // 피드를 alias로 그룹화
    playbackQueue = groupFeedsByAlias(homeFeedItems)
    currentGroupIndex = 0
    currentItemIndex = 0

    print("🎵 재생 시작: \(playbackQueue.count)개 그룹")

    // 첫 번째 그룹부터 재생 시작
    playCurrentGroup()
  }

  /// 재생 중단 시 큐 초기화
  func stopPlayback() {
    SpeechService.shared.stop()
    playbackQueue = []
    currentGroupIndex = 0
    currentItemIndex = 0
  }

  /// 현재 그룹 재생 (카테고리명 먼저, 그 다음 summary들)
  private func playCurrentGroup() {
    guard currentGroupIndex < playbackQueue.count else {
      // 모든 그룹 재생 완료
      print("✅ 모든 피드 재생 완료")
      return
    }

    let currentGroup = playbackQueue[currentGroupIndex]

    // 현재 카테고리 업데이트
    DispatchQueue.main.async { [weak self] in
      self?.currentCategoryName = currentGroup.category
    }

    // 카테고리명 먼저 재생
    print("📢 카테고리: \(currentGroup.category)")
    SpeechService.shared.speak(text: currentGroup.category, rate: Float(playbackRate))

    // 카테고리명 재생 후 첫 번째 아이템은 playNextItem에서 재생됨
    currentItemIndex = 0
  }

  /// 다음 아이템 재생
  private func playNextItem() {
    guard currentGroupIndex < playbackQueue.count else {
      return
    }

    let currentGroup = playbackQueue[currentGroupIndex]

    // 현재 그룹의 모든 아이템을 재생했으면 다음 그룹으로
    if currentItemIndex >= currentGroup.items.count {
      currentGroupIndex += 1
      currentItemIndex = 0

      if currentGroupIndex < playbackQueue.count {
        // 다음 그룹 재생
        playCurrentGroup()
      } else {
        // 모든 그룹 재생 완료
        print("✅ 모든 피드 재생 완료")
      }
      return
    }

    // 현재 그룹의 다음 아이템 재생
    let item = currentGroup.items[currentItemIndex]
    print("📢 재생: \(item.summaryContent)")
    SpeechService.shared.speak(text: item.summaryContent, rate: Float(playbackRate))

    currentItemIndex += 1
  }
}
