//
//  HomeViewModel.swift
//  today-s-sound
//
//  Created by 하승연 on 9/28/25.
//

import Combine
import Foundation

class HomeViewModel: ObservableObject {
  @Published var playbackRate: Double = 1.0
  @Published var currentCategoryName: String = ""
  @Published var recentAlerts: [Alert] = []
  @Published var homeFeedItems: [HomeFeedItemResponse] = []
  @Published var isLoading: Bool = false
  @Published var errorMessage: String?

  private let apiService: APIService
  private var cancellables = Set<AnyCancellable>()

  init(apiService: APIService = APIService()) {
    self.apiService = apiService
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
      receiveValue: { [weak self] response in
        guard let self else { return }
        let feedItems = response.items
        homeFeedItems = feedItems
        print("✅ 홈 피드 조회 성공: \(feedItems.count)개")
      }
    )
    .store(in: &cancellables)
  }

}
