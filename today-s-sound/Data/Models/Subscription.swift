import Foundation

struct Subscription: Codable, Identifiable {
  let id: UUID
  let name: String
  let url: String
}
