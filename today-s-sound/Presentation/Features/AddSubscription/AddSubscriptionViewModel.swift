import Combine
import Foundation

class AddSubscriptionViewModel: ObservableObject {
  @Published var urlText: String = ""
  @Published var nameText: String = ""
  @Published var keywordsText: String = ""
  @Published var isUrgent: Bool = false
}
