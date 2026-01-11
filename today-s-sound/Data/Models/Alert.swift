import Foundation

struct Alert: Codable, Identifiable {
  let id: UUID
  let title: String
  let content: String
  let date: Date
}
