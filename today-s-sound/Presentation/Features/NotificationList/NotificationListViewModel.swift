import Combine
import Foundation

class NotificationListViewModel: ObservableObject {
  @Published var alerts: [Alert] = []

  init() {
    loadMock()
  }

  private func loadMock() {
    alerts = [
      Alert(id: UUID(), title: "일이삼사오육칠팔", content: "본문 예시", date: Date().addingTimeInterval(-7200), isUrgent: true),
      Alert(id: UUID(), title: "잡코리아 채용 공고", content: "본문 예시 2", date: Date().addingTimeInterval(-10800), isUrgent: false),
      Alert(id: UUID(), title: "동국대 도서관 휴관 안내", content: "본문 예시 3", date: Date().addingTimeInterval(-14400), isUrgent: true)
    ]
  }
}
