//
//  SubscriptionListViewModel.swift
//  today-s-sound
//
//  Updated to use offset-based pagination
//

import Combine
import SwiftUI

class SubscriptionListViewModel: ObservableObject {
  @Published var subscriptions: [SubscriptionItem] = []
  @Published var isLoading: Bool = false
  @Published var isLoadingMore: Bool = false
  @Published var errorMessage: String?

  private let apiService: APIService
  private var cancellables = Set<AnyCancellable>()

  // 오프셋 기반 페이지네이션
  private var currentPage: Int = 0
  private let pageSize: Int = 5
  private var hasMoreData: Bool = true

  init(apiService: APIService = APIService()) {
    self.apiService = apiService
  }

  /// 구독 목록 불러오기
  func loadSubscriptions() {
    // 이미 로딩 중이거나 더 이상 데이터가 없으면 리턴
    guard !isLoading, !isLoadingMore, hasMoreData else {
      print("⏸️ 로딩 중단: isLoading=\(isLoading), isLoadingMore=\(isLoadingMore), hasMoreData=\(hasMoreData)")
      return
    }

    guard let userId = Keychain.getString(for: KeychainKey.userId),
          let deviceSecret = Keychain.getString(for: KeychainKey.deviceSecret)
    else {
      errorMessage = "사용자 정보가 없습니다"
      return
    }

    // 첫 로딩인지 더 불러오기인지 구분
    if currentPage == 0 {
      isLoading = true
    } else {
      isLoadingMore = true
    }
    errorMessage = nil

    print("📡 구독 목록 요청: page=\(currentPage), size=\(pageSize)")

    apiService.getSubscriptions(
      userId: userId,
      deviceSecret: deviceSecret,
      page: currentPage,
      size: pageSize
    )
    .receive(on: DispatchQueue.main)
    .sink(
      receiveCompletion: { [weak self] completion in
        guard let self else { return }
        isLoading = false
        isLoadingMore = false

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

          print("❌ 구독 목록 조회 실패: \(errorMessage ?? "")")
        }
      },
      receiveValue: { [weak self] response in
        guard let self else { return }

        let newItems = response.subscriptions

        // 기존 목록에 추가 (서버에서 이미 정렬됨!)
        subscriptions.append(contentsOf: newItems)

        // 다음 페이지로 이동
        currentPage += 1

        // 받은 개수가 pageSize보다 적으면 더 이상 데이터 없음
        if newItems.count < pageSize {
          hasMoreData = false
          print("🏁 마지막 페이지 도달: 받은 개수(\(newItems.count)) < 예상(\(pageSize))")
        }

        print("✅ 구독 목록 조회 성공: \(newItems.count)개 추가 (전체: \(subscriptions.count)개)")
      }
    )
    .store(in: &cancellables)
  }

  /// 새로고침 (처음부터 다시 로드)
  func refresh() {
    print("🔄 새로고침")
    subscriptions = []
    currentPage = 0
    hasMoreData = true
    errorMessage = nil
    loadSubscriptions()
  }

  /// 특정 아이템이 보일 때 호출 (무한 스크롤 트리거)
  func loadMoreIfNeeded(currentItem item: SubscriptionItem) {
    // View에서 이미 threshold 체크했으므로 바로 로드
    loadSubscriptions()
  }

  /// 구독 삭제
  func deleteSubscription(_ subscription: SubscriptionItem) {
    guard let userId = Keychain.getString(for: KeychainKey.userId),
          let deviceSecret = Keychain.getString(for: KeychainKey.deviceSecret)
    else {
      errorMessage = "사용자 정보가 없습니다"
      return
    }

    print("🗑️ 구독 삭제 요청: subscriptionId=\(subscription.id)")

    apiService.deleteSubscription(
      userId: userId,
      deviceSecret: deviceSecret,
      subscriptionId: subscription.id
    )
    .receive(on: DispatchQueue.main)
    .sink(
      receiveCompletion: { [weak self] completion in
        guard let self else { return }

        switch completion {
        case .finished:
          // 삭제 성공 시 목록에서 제거
          self.subscriptions.removeAll { $0.id == subscription.id }
          print("✅ 구독 삭제 성공: subscriptionId=\(subscription.id)")

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

          print("❌ 구독 삭제 실패: \(self.errorMessage ?? "")")
        }
      },
      receiveValue: { [weak self] response in
        guard let self else { return }
        print("📥 구독 삭제 응답: \(response.message)")
      }
    )
    .store(in: &cancellables)
  }
}
