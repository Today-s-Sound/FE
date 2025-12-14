import Combine
import Foundation

final class AddSubscriptionViewModel: ObservableObject {
  // 입력값
  @Published var urlText: String = ""
  @Published var nameText: String = ""
  @Published var isUrgent: Bool = false

  // 키워드 선택 관련
  @Published var selectedKeywords: [String] = []
  @Published var showKeywordSelector: Bool = false

  // API 상태
  @Published var isLoading: Bool = false
  @Published var errorMessage: String?
  @Published var isLoadingKeywords: Bool = false
  @Published var keywordErrorMessage: String?

  // 키워드 목록 (API에서 가져옴)
  @Published var availableKeywords: [String] = []

  private let apiService: APIService
  private var cancellables = Set<AnyCancellable>()

  init(apiService: APIService = APIService()) {
    self.apiService = apiService
  }

  /// URL이 비어있지 않을 때만 전송 가능
  var isSubmitEnabled: Bool {
    !urlText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  /// 현재 입력 상태를 기반으로 Request payload 생성
  func makeRequestPayload() -> CreateSubscriptionRequest {
    CreateSubscriptionRequest(
      url: urlText.trimmingCharacters(in: .whitespacesAndNewlines),
      keywords: selectedKeywords,
      alias: nameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ? nil
        : nameText.trimmingCharacters(in: .whitespacesAndNewlines),
      isUrgent: isUrgent
    )
  }

  /// 구독 생성 API 호출
  func createSubscription(completion: @escaping (Bool) -> Void) {
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

    let request = makeRequestPayload()

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

  // MARK: - 키워드 선택 로직

  func addKeyword(_ keyword: String) {
    let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
    if !trimmed.isEmpty, !selectedKeywords.contains(trimmed) {
      selectedKeywords.append(trimmed)
    }
  }

  func removeKeyword(_ keyword: String) {
    selectedKeywords.removeAll { $0 == keyword }
  }

  func toggleKeyword(_ keyword: String) {
    if selectedKeywords.contains(keyword) {
      removeKeyword(keyword)
    } else {
      addKeyword(keyword)
    }
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
          // KeywordItem 배열에서 name만 추출
          let keywords = response.keywords.map(\.name)
          availableKeywords = keywords

          print("✅ 키워드 목록 조회 성공: \(keywords.count)개")
        }
      )
      .store(in: &cancellables)
  }
}
