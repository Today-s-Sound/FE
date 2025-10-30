import Combine
import Foundation

class AddSubscriptionViewModel: ObservableObject {
  @Published var urlText: String = ""
  @Published var nameText: String = ""
  @Published var isUrgent: Bool = false
  @Published var selectedKeywords: [String] = []
  @Published var showKeywordSelector: Bool = false

  let availableKeywords = ["장애인", "긴급속보", "장학금", "교직부공지사항", "학생회", "도서관"]

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
