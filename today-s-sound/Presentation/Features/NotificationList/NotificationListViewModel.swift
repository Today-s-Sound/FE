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
    print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("📞 loadAlarms() 호출됨!")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━")

    // 이미 로딩 중이거나 더 이상 데이터가 없으면 리턴
    guard !isLoading, !isLoadingMore, hasMoreData else {
      print("⏸️ 알림 로딩 중단: isLoading=\(isLoading), isLoadingMore=\(isLoadingMore), hasMoreData=\(hasMoreData)")
      return
    }
    print("✅ 로딩 상태 체크 통과")

    guard let userId = Keychain.getString(for: KeychainKey.userId),
          let deviceSecret = Keychain.getString(for: KeychainKey.deviceSecret)
    else {
      print("❌ 키체인에서 userId 또는 deviceSecret을 찾을 수 없음!")
      errorMessage = "사용자 정보가 없습니다"
      return
    }
    print("✅ 키체인 정보 획득 성공")
    print("   userId: \(userId)")
    print("   deviceSecret: \(deviceSecret.prefix(20))...")

    // 첫 로딩인지 더 불러오기인지 구분
    if currentPage == 0 {
      isLoading = true
      print("📂 첫 로딩 시작")
    } else {
      isLoadingMore = true
      print("📂 추가 로딩 시작")
    }
    errorMessage = nil

    print("📡 알림 목록 API 요청 준비:")
    print("   URL: http://localhost:8080/api/alarms")
    print("   page: \(currentPage)")
    print("   size: \(pageSize)")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━\n")

    apiService.getAlarms(
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

          print("❌ 알림 목록 조회 실패: \(errorMessage ?? "")")
        }
      },
      receiveValue: { [weak self] response in
        guard let self else { return }

        let newItems = response.alarms

        // 기존 목록에 추가 (서버에서 이미 정렬됨!)
        alarms.append(contentsOf: newItems)

        // 다음 페이지로 이동
        currentPage += 1

        // 받은 개수가 pageSize보다 적으면 더 이상 데이터 없음
        if newItems.count < pageSize {
          hasMoreData = false
          print("🏁 마지막 페이지 도달: 받은 개수(\(newItems.count)) < 예상(\(pageSize))")
        }

        print("✅ 알림 목록 조회 성공: \(newItems.count)개 추가 (전체: \(alarms.count)개)")
      }
    )
    .store(in: &cancellables)
  }

  /// 새로고침 (처음부터 다시 로드)
  func refresh() {
    print("🔄 알림 새로고침")
    alarms = []
    currentPage = 0
    hasMoreData = true
    errorMessage = nil
    loadAlarms()
  }

  /// 특정 아이템이 보일 때 호출 (무한 스크롤 트리거)
  func loadMoreIfNeeded(currentItem item: AlarmItem) {
    // View에서 이미 threshold 체크했으므로 바로 로드
    loadAlarms()
  }
}
