//
//  NotificationListViewModel.swift
//  today-s-sound
//
//  Updated to use real API with infinite scroll
//

import Combine
import SwiftUI

class NotificationListViewModel: ObservableObject {
  @Published var alarms: [AlarmItem] = []
  @Published var isLoading: Bool = false
  @Published var isLoadingMore: Bool = false
  @Published var errorMessage: String?
  var disableAutoLoad: Bool = false

  private let apiService: APIService
  private var cancellables = Set<AnyCancellable>()

  // 오프셋 기반 페이지네이션
  private var currentPage: Int = 0
  private let pageSize: Int = 10
  private var hasMoreData: Bool = true

  init(apiService: APIService = APIService()) {
    self.apiService = apiService
  }

  /// 알림 목록 불러오기
  func loadAlarms() {
    guard !disableAutoLoad else { return }

    // 이미 로딩 중이거나 더 이상 데이터가 없으면 리턴
    guard !isLoading, !isLoadingMore, hasMoreData else {
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

    apiService.getAlarms(
      userId: userId,
      deviceSecret: deviceSecret,
      page: currentPage,
      size: pageSize
    )
    // getAlarms의 리턴 타입은 AnyPublisher<[AlarmItem], APIError> 라고 가정
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
        }
      },
      receiveValue: { [weak self] response in
        guard let self else { return }

        let newItems = response.alarms

        // 새 데이터 추가
        alarms.append(contentsOf: newItems)

        // 다음 페이지
        currentPage += 1

        // 받은 개수가 pageSize보다 적으면 마지막 페이지
        if newItems.count < pageSize {
          hasMoreData = false
        }
      }
    )
    .store(in: &cancellables)
  }

  /// 새로고침 (처음부터 다시 로드)
  func refresh() {
    alarms = []
    currentPage = 0
    hasMoreData = true
    errorMessage = nil
    loadAlarms()
  }

  /// 특정 아이템이 보일 때 호출 (무한 스크롤 트리거)
  func loadMoreIfNeeded(currentItem item: AlarmItem) {
    // 마지막 아이템 근처에서만 더 불러오기
    guard let last = alarms.last else { return }
    if item.id == last.id {
      loadAlarms()
    }
  }

  /// 스와이프 삭제 처리 (추후 API 연동 시 여기에서 호출)
  func delete(alarm: AlarmItem) {
    // 1) 로컬 리스트에서 삭제
    alarms.removeAll { $0.id == alarm.id }

    // 2) TODO: 서버 삭제 API 연동
    // apiService.deleteAlarm(id: alarm.subscriptionId)
    //   .sink { ... } receiveValue: { ... }
    //   .store(in: &cancellables)
  }
}
