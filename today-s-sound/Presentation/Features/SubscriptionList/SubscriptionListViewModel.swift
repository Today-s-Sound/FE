
import Foundation
import Combine

class SubscriptionListViewModel: ObservableObject {
    @Published var subscriptions: [Subscription] = []

    init() {
        loadMock()
    }

    private func loadMock() {
        subscriptions = [
            Subscription(id: UUID(), name: "동국대학교 공지사항", url: "https://www.dongguk.edu"),
            Subscription(id: UUID(), name: "네이버 연합뉴스 속보", url: "https://news.naver.com")
        ]
    }
}
