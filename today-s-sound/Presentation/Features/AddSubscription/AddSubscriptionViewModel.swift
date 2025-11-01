import Combine
import Foundation

@MainActor
final class AddSubscriptionViewModel: ObservableObject {
  // MARK: - Form

  @Published var urlText: String = ""
  @Published var nameText: String = "" // (보류) API 확장 시 사용
  @Published var isUrgent: Bool = false // (보류)
  @Published var selectedKeywords: [String] = [] // (보류)
  @Published var showKeywordSelector: Bool = false

  let availableKeywords = ["장애인", "긴급속보", "장학금", "교직부공지사항", "학생회", "도서관"]

  // MARK: - UI State

  @Published private(set) var isLoading: Bool = false
  @Published private(set) var errorMessage: String?
  @Published private(set) var successSubscriptionId: Int?

  // MARK: - Dependency

  private unowned let session: SessionStore

  init(session: SessionStore) {
    self.session = session
  }

  // MARK: - Keyword helpers (그대로 유지)

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
    if selectedKeywords.contains(keyword) { removeKeyword(keyword) }
    else { addKeyword(keyword) }
  }

  // MARK: - Validation

  var canSubmit: Bool {
    guard let comps = URLComponents(string: urlText.trimmingCharacters(in: .whitespacesAndNewlines)),
          let scheme = comps.scheme, let host = comps.host, !host.isEmpty,
          ["http", "https"].contains(scheme.lowercased())
    else { return false }
    return !isLoading
  }

  // MARK: - Action

  func submit() {
    guard canSubmit else {
      errorMessage = "유효한 URL을 입력해주세요 (http/https)."
      return
    }
    errorMessage = nil
    successSubscriptionId = nil
    isLoading = true

    let url = urlText.trimmingCharacters(in: .whitespacesAndNewlines)

    Task {
      // ── 옵션 A: createSubscription 이 반환값이 없는(VOID) 경우 ───────────────
      // await session.createSubscription(url: url)
      // if let err = session.lastError { self.errorMessage = err } else { self.successSubscriptionId = 0 /* 더미 */; self.resetForm() }
      // self.isLoading = false

      // ── 옵션 B: createSubscription 이 subscriptionId(Int)을 반환하도록 한 경우 ──
      // (아래 줄만 주석 해제하고, SessionStore 쪽 시그니처를 Int 반환으로 바꿔주면 더 좋음)
      do {
        let id = try await session.createSubscriptionReturningId(url: url)
        self.successSubscriptionId = id
        self.resetForm()
      } catch {
        self.errorMessage = error.localizedDescription
      }
      self.isLoading = false
    }
  }

  private func resetForm() {
    urlText = ""
    // nameText/isUrgent/selectedKeywords는 향후 API 확장 시 함께 전송하도록 남겨둠
  }
}
