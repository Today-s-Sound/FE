import Foundation

final class AddSubscriptionViewModel: ObservableObject {
  // 입력값
  @Published var urlText: String = ""
  @Published var nameText: String = ""
  @Published var isUrgent: Bool = false

  // 키워드 선택 관련
  @Published var selectedKeywords: [String] = []
  @Published var showKeywordSelector: Bool = false

  // 키워드 목록 (더미 데이터 10개)
  @Published var availableKeywords: [String] = [
    "장학금",
    "학사공지",
    "수업",
    "교직",
    "학생회",
    "봉사활동",
    "대회",
    "모집공고",
    "실습",
    "교환학생"
  ]

  /// URL이 비어있지 않을 때만 전송 가능
  var isSubmitEnabled: Bool {
    !urlText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  /// 서버로 보낼 요청 DTO (나중에 API 연동 시 그대로 쓰면 됨)
  struct NewSubscriptionRequest: Encodable {
    let url: String
    let name: String?
    let isUrgent: Bool
    let keywords: [String]
  }

  /// 현재 입력 상태를 기반으로 Request payload 생성
  func makeRequestPayload() -> NewSubscriptionRequest {
    NewSubscriptionRequest(
      url: urlText.trimmingCharacters(in: .whitespacesAndNewlines),
      name: nameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ? nil
        : nameText.trimmingCharacters(in: .whitespacesAndNewlines),
      isUrgent: isUrgent,
      keywords: selectedKeywords
    )
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
}
