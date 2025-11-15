import Combine
import Foundation

class AddSubscriptionViewModel: ObservableObject {
  @Published var urlText: String = ""
  @Published var nameText: String = ""
  @Published var isUrgent: Bool = false
  @Published var selectedKeywords: [String] = []
  @Published var showKeywordSelector: Bool = false
  @Published var availableKeywords: [String] = []
  @Published var isLoadingKeywords: Bool = false
  @Published var keywordErrorMessage: String?

  private let apiService: APIService
  private var cancellables = Set<AnyCancellable>()

  init(apiService: APIService = APIService()) {
    self.apiService = apiService
  }

  /// 서버에서 키워드 목록 불러오기
  func loadKeywords() {
    guard !isLoadingKeywords else { return }

    isLoadingKeywords = true
    keywordErrorMessage = nil

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
          // 서버에서 받은 KeywordItem 배열을 String 배열로 변환
          availableKeywords = response.keywords.map(\.name)
          print("✅ 키워드 목록 조회 성공: \(availableKeywords.count)개")
        }
      )
      .store(in: &cancellables)
  }

  func addKeyword(_ keyword: String) {
    let trimmed = keyword.trimmingCharacters(in: .whitespaces)
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
}
