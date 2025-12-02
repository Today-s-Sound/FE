import Combine
import Foundation

@MainActor
final class FeedViewModel: ObservableObject {
  @Published var items: [FeedItem] = []
  @Published var isLoading: Bool = false
  @Published var isLoadingMore: Bool = false
  @Published var errorMessage: String?

  private let apiService: APIService
  private var cancellables = Set<AnyCancellable>()

  // 페이지네이션
  private var currentPage: Int = 0
  private let pageSize: Int = 10
  private var hasMoreData: Bool = true

  init(apiService: APIService = APIService()) {
    self.apiService = apiService
  }

  /// 피드 불러오기
  func loadFeeds() {
    guard !isLoading, !isLoadingMore, hasMoreData else { return }

    guard let userId = Keychain.getString(for: KeychainKey.userId),
          let deviceSecret = Keychain.getString(for: KeychainKey.deviceSecret)
    else {
      errorMessage = "사용자 정보가 없습니다"
      return
    }

    if currentPage == 0 {
      isLoading = true
    } else {
      isLoadingMore = true
    }
    errorMessage = nil

    print("📡 피드 목록 요청: page=\(currentPage), size=\(pageSize)")

    apiService.getFeeds(
      userId: userId,
      deviceSecret: deviceSecret,
      page: currentPage,
      size: pageSize
    )
    .receive(on: DispatchQueue.main)
    .sink(
      receiveCompletion: { [weak self] completion in
        guard let self else { return }
        self.isLoading = false
        self.isLoadingMore = false

        switch completion {
        case .finished:
          break

        case let .failure(error):
          switch error {
          case let .serverError(statusCode):
            self.errorMessage = "서버 오류 (상태: \(statusCode))"

          case .decodingFailed:
            self.errorMessage = "응답 처리 실패"

          case let .requestFailed(requestError):
            self.errorMessage = "요청 실패: \(requestError.localizedDescription)"

          case .invalidURL:
            self.errorMessage = "잘못된 URL"

          case .unknown:
            self.errorMessage = "알 수 없는 오류"
          }

          print("❌ 피드 목록 조회 실패: \(self.errorMessage ?? "")")
        }
      },
      receiveValue: { [weak self] response in
        guard let self else { return }

        let feedItems = response.feeds

        // FeedItemResponse를 FeedItem으로 변환
        let newItems = feedItems.map { response -> FeedItem in
          // summaryContent를 제목으로 사용 (디자인에 맞춰 제목만 표시)
          FeedItem(
            id: UUID(),
            alias: response.alias,
            summary: response.summaryContent, // 내용도 동일하게 사용
            source: response.alias,
            publishedAt: self.parseTimeAgo(response.timeAgo),
            timeAgo: response.timeAgo
          )
        }

        self.items.append(contentsOf: newItems)
        self.currentPage += 1

        if feedItems.count < self.pageSize {
          self.hasMoreData = false
          print("🏁 마지막 페이지 도달: 받은 개수(\(feedItems.count)) < 예상(\(self.pageSize))")
        }

        print("✅ 피드 목록 조회 성공: \(feedItems.count)개 추가 (전체: \(self.items.count)개)")
      }
    )
    .store(in: &self.cancellables)
  }

  /// 새로고침
  func refresh() async {
    isLoading = true
    errorMessage = nil
    items = []
    currentPage = 0
    hasMoreData = true

    // Combine을 async/await로 변환
    await withCheckedContinuation { [weak self] continuation in
      guard let self else {
        continuation.resume()
        return
      }
      
      guard let userId = Keychain.getString(for: KeychainKey.userId),
            let deviceSecret = Keychain.getString(for: KeychainKey.deviceSecret)
      else {
        self.errorMessage = "사용자 정보가 없습니다"
        self.isLoading = false
        continuation.resume()
        return
      }

      self.apiService.getFeeds(
        userId: userId,
        deviceSecret: deviceSecret,
        page: 0,
        size: self.pageSize
      )
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { [weak self] completion in
          guard let self else {
            continuation.resume()
            return
          }
          self.isLoading = false

          switch completion {
          case .finished:
            break

          case let .failure(error):
            switch error {
            case let .serverError(statusCode):
              self.errorMessage = "서버 오류 (상태: \(statusCode))"

            case .decodingFailed:
              self.errorMessage = "응답 처리 실패"

            case let .requestFailed(requestError):
              self.errorMessage = "요청 실패: \(requestError.localizedDescription)"

            case .invalidURL:
              self.errorMessage = "잘못된 URL"

            case .unknown:
              self.errorMessage = "알 수 없는 오류"
            }

            print("❌ 피드 새로고침 실패: \(self.errorMessage ?? "")")
          }

          continuation.resume()
        },
        receiveValue: { [weak self] response in
          guard let self else { return }

          let feedItems = response.feeds

          let newItems = feedItems.map { response -> FeedItem in
            // summaryContent를 제목으로 사용 (디자인에 맞춰 제목만 표시)
            FeedItem(
              id: UUID(),
              alias: response.alias,
              summary: response.summaryContent, // 내용도 동일하게 사용
              source: response.alias,
              publishedAt: self.parseTimeAgo(response.timeAgo),
              timeAgo: response.timeAgo
            )
          }

          self.items = newItems
          self.currentPage = 1
          self.hasMoreData = feedItems.count >= self.pageSize

          print("✅ 피드 새로고침 성공: \(feedItems.count)개")
        }
      )
      .store(in: &self.cancellables)
    }
  }

  /// 특정 아이템이 보일 때 호출 (무한 스크롤)
  func loadMoreIfNeeded(currentItem item: FeedItem) {
    guard !isLoading, !isLoadingMore, hasMoreData else { return }
    loadFeeds()
  }

  /// timeAgo 문자열을 Date로 변환 (예: "1시간 전" -> Date)
  private func parseTimeAgo(_ timeAgo: String) -> Date {
    // 간단한 파싱 (실제로는 더 정교한 파싱 필요)
    // 예: "1시간 전", "30분 전", "2일 전" 등
    let calendar = Calendar.current
    var date = Date()

    if timeAgo.contains("시간") {
      if let hours = Int(timeAgo.replacingOccurrences(of: "시간 전", with: "").trimmingCharacters(in: .whitespaces)) {
        date = calendar.date(byAdding: .hour, value: -hours, to: date) ?? date
      }
    } else if timeAgo.contains("분") {
      if let minutes = Int(timeAgo.replacingOccurrences(of: "분 전", with: "").trimmingCharacters(in: .whitespaces)) {
        date = calendar.date(byAdding: .minute, value: -minutes, to: date) ?? date
      }
    } else if timeAgo.contains("일") {
      if let days = Int(timeAgo.replacingOccurrences(of: "일 전", with: "").trimmingCharacters(in: .whitespaces)) {
        date = calendar.date(byAdding: .day, value: -days, to: date) ?? date
      }
    }

    return date
  }
}
