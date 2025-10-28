import Foundation

struct AnonymousUserResponse: Codable {
  let errorCode: Int?
  let message: String
  let result: AnonymousUserResult
}

struct AnonymousUserResult: Codable {
  let userId: String

  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
  }
}


