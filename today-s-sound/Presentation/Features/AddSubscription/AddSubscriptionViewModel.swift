import Combine
import Foundation

final class AddSubscriptionViewModel: ObservableObject {
  // 수정 모드 관련
  let subscriptionToEdit: SubscriptionItem?
  var isEditMode: Bool { subscriptionToEdit != nil }
  private var subscriptionId: Int64? { subscriptionToEdit?.id }

  // 입력값
  @Published var urlText: String = ""
  @Published var selectedURL: URLItem? = nil
  @Published var nameText: String = ""
  @Published var isAlarmEnabled: Bool = true

  // URL 선택 관련
  @Published var showURLSelector: Bool = false

  // 키워드 선택 관련
  @Published var selectedKeywordIds: [Int64] = []
  @Published var showKeywordSelector: Bool = false

  // API 상태
  @Published var isLoading: Bool = false
  @Published var errorMessage: String?
  @Published var isLoadingURLs: Bool = false
  @Published var urlErrorMessage: String?
  @Published var isLoadingKeywords: Bool = false
  @Published var keywordErrorMessage: String?

  // URL 목록 (API에서 가져옴)
  @Published var availableURLs: [URLItem] = []
  // 키워드 목록 (API에서 가져옴) - ID와 name을 함께 저장
  @Published var availableKeywords: [KeywordItem] = []

  private let apiService: APIService
  private var cancellables = Set<AnyCancellable>()

  init(subscriptionToEdit: SubscriptionItem? = nil, apiService: APIService = APIService()) {
    self.subscriptionToEdit = subscriptionToEdit
    self.apiService = apiService

    // 수정 모드일 때 기존 값 로드
    if let subscription = subscriptionToEdit {
      nameText = subscription.alias
      isAlarmEnabled = subscription.isAlarmEnabled
      selectedKeywordIds = subscription.keywords.map(\.id)
      // URL은 수정 불가이므로 표시만 하기 위해 URLItem을 찾아서 설정
      // 실제로는 URL 선택 섹션을 비활성화할 예정
    }
  }

  /// URL이 선택되었을 때만 전송 가능 (생성 모드)
  /// 수정 모드에서는 항상 활성화
  var isSubmitEnabled: Bool {
    isEditMode ? true : selectedURL != nil
  }

  /// 현재 입력 상태를 기반으로 Request payload 생성
  func makeRequestPayload() -> CreateSubscriptionRequest? {
    guard let selectedURL else { return nil }
    return CreateSubscriptionRequest(
      urlId: selectedURL.id,
      keywordIds: selectedKeywordIds,
      alias: nameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ? selectedURL.title
        : nameText.trimmingCharacters(in: .whitespacesAndNewlines),
      isAlarmEnabled: isAlarmEnabled
    )
  }

  /// 구독 생성 또는 수정 API 호출
  func createSubscription(completion: @escaping (Bool) -> Void) {
    if isEditMode {
      updateSubscription(completion: completion)
    } else {
      createSubscriptionInternal(completion: completion)
    }
  }

  /// 구독 생성 API 호출
  private func createSubscriptionInternal(completion: @escaping (Bool) -> Void) {
    guard !isLoading else { return }

    guard let userId = Keychain.getString(for: KeychainKey.userId),
          let deviceSecret = Keychain.getString(for: KeychainKey.deviceSecret)
    else {
      errorMessage = "사용자 정보가 없습니다"
      completion(false)
      return
    }

    isLoading = true
    errorMessage = nil

    guard let request = makeRequestPayload() else {
      errorMessage = "URL을 선택해주세요"
      isLoading = false
      completion(false)
      return
    }

    print("📤 구독 생성 요청:", request)

    apiService.createSubscription(
      userId: userId,
      deviceSecret: deviceSecret,
      request: request
    )
    .receive(on: DispatchQueue.main)
    .sink(
      receiveCompletion: { [weak self] apiCompletion in
        guard let self else { return }
        isLoading = false

        switch apiCompletion {
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

          print("❌ 구독 생성 실패: \(errorMessage ?? "")")
          completion(false)
        }
      },
      receiveValue: { [weak self] response in
        guard let self else { return }
        print("✅ 구독 생성 성공: subscriptionId=\(response.subscriptionId)")
        completion(true)
      }
    )
    .store(in: &cancellables)
  }

  /// 구독 수정 API 호출
  private func updateSubscription(completion: @escaping (Bool) -> Void) {
    guard !isLoading else { return }
    guard let subscriptionId else {
      errorMessage = "구독 정보가 없습니다"
      completion(false)
      return
    }

    guard let userId = Keychain.getString(for: KeychainKey.userId),
          let deviceSecret = Keychain.getString(for: KeychainKey.deviceSecret)
    else {
      errorMessage = "사용자 정보가 없습니다"
      completion(false)
      return
    }

    isLoading = true
    errorMessage = nil

    let request = UpdateSubscriptionRequest(
      keywordIds: selectedKeywordIds,
      alias: nameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ? nil
        : nameText.trimmingCharacters(in: .whitespacesAndNewlines),
      isAlarmEnabled: isAlarmEnabled
    )

    print("📤 구독 수정 요청:", request)

    apiService.updateSubscription(
      userId: userId,
      deviceSecret: deviceSecret,
      subscriptionId: subscriptionId,
      request: request
    )
    .receive(on: DispatchQueue.main)
    .sink(
      receiveCompletion: { [weak self] apiCompletion in
        guard let self else { return }
        isLoading = false

        switch apiCompletion {
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

          print("❌ 구독 수정 실패: \(errorMessage ?? "")")
          completion(false)
        }
      },
      receiveValue: { [weak self] _ in
        guard let self else { return }
        print("✅ 구독 수정 성공: subscriptionId=\(subscriptionId)")
        completion(true)
      }
    )
    .store(in: &cancellables)
  }

  // MARK: - URL 선택 로직

  func selectURL(_ url: URLItem) {
    selectedURL = url
    urlText = url.link
  }

  // MARK: - 키워드 선택 로직

  func addKeyword(_ keywordId: Int64) {
    if !selectedKeywordIds.contains(keywordId) {
      selectedKeywordIds.append(keywordId)
    }
  }

  func removeKeyword(_ keywordId: Int64) {
    selectedKeywordIds.removeAll { $0 == keywordId }
  }

  func toggleKeyword(_ keywordId: Int64) {
    if selectedKeywordIds.contains(keywordId) {
      removeKeyword(keywordId)
    } else {
      addKeyword(keywordId)
    }
  }

  /// 선택된 키워드의 이름 목록 (UI 표시용)
  var selectedKeywordNames: [String] {
    availableKeywords
      .filter { selectedKeywordIds.contains($0.id) }
      .map(\.name)
  }

  // MARK: - URL 목록 로드

  /// URL 목록을 API에서 가져오기
  func loadURLs() {
    guard !isLoadingURLs else { return }

    isLoadingURLs = true
    urlErrorMessage = nil

    print("📡 URL 목록 요청")

    apiService.getURLs()
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { [weak self] completion in
          guard let self else { return }
          isLoadingURLs = false

          switch completion {
          case .finished:
            break

          case let .failure(error):
            switch error {
            case let .serverError(statusCode):
              urlErrorMessage = "서버 오류 (상태: \(statusCode))"

            case .decodingFailed:
              urlErrorMessage = "응답 처리 실패"

            case let .requestFailed(requestError):
              urlErrorMessage = "요청 실패: \(requestError.localizedDescription)"

            case .invalidURL:
              urlErrorMessage = "잘못된 URL"

            case .unknown:
              urlErrorMessage = "알 수 없는 오류"
            }

            print("❌ URL 목록 조회 실패: \(urlErrorMessage ?? "")")
          }
        },
        receiveValue: { [weak self] response in
          guard let self else { return }
          availableURLs = response.urls

          print("✅ URL 목록 조회 성공: \(response.urls.count)개")
        }
      )
      .store(in: &cancellables)
  }

  // MARK: - 키워드 목록 로드

  /// 키워드 목록을 API에서 가져오기
  func loadKeywords() {
    guard !isLoadingKeywords else { return }

    isLoadingKeywords = true
    keywordErrorMessage = nil

    print("📡 키워드 목록 요청")

    apiService.getKeywords()
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { [weak self] completion in
          guard let self else { return }
          isLoadingKeywords = false

          switch completion {
          case .finished:
            break

          case let .failure(error):
            switch error {
            case let .serverError(statusCode):
              keywordErrorMessage = "서버 오류 (상태: \(statusCode))"

            case .decodingFailed:
              keywordErrorMessage = "응답 처리 실패"

            case let .requestFailed(requestError):
              keywordErrorMessage = "요청 실패: \(requestError.localizedDescription)"

            case .invalidURL:
              keywordErrorMessage = "잘못된 URL"

            case .unknown:
              keywordErrorMessage = "알 수 없는 오류"
            }

            print("❌ 키워드 목록 조회 실패: \(keywordErrorMessage ?? "")")
          }
        },
        receiveValue: { [weak self] response in
          guard let self else { return }
          // KeywordItem 전체를 저장 (ID와 name 모두 필요)
          availableKeywords = response.keywords

          print("✅ 키워드 목록 조회 성공: \(response.keywords.count)개")
        }
      )
      .store(in: &cancellables)
  }
}
