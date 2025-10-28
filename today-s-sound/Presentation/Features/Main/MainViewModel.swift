import Combine
import Foundation

class MainViewModel: ObservableObject {
  @Published var playbackRate: Double = 1.0
  @Published var currentCategoryName: String = "동국대학교 공지사항"
  @Published var recentAlerts: [Alert] = []

  private var cancellables = Set<AnyCancellable>()

  init() {
    loadMockAlerts()
  }

  func increaseRate() {
    playbackRate = min(2.0, (playbackRate * 10 + 1).rounded() / 10)
  }

  func decreaseRate() {
    playbackRate = max(0.5, (playbackRate * 10 - 1).rounded() / 10)
  }

  func playAlert(_ alert: Alert) {
    SpeechService.shared.speak(text: alert.title)
  }

  private func loadMockAlerts() {
    recentAlerts = [
      Alert(id: UUID(), title: "일이삼사오육칠팔", content: "공지 내용 예시", date: Date().addingTimeInterval(-7200), isUrgent: true),
      Alert(id: UUID(), title: "잡코리아 채용 공고", content: "채용 소식", date: Date().addingTimeInterval(-10800), isUrgent: false)
    ]
  }
}
