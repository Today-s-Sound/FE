import Foundation

// MARK: - Subscription Response Models

/// 구독 목록 응답 (서버 Envelope 구조)
struct SubscriptionListResponse: Codable {
  let errorCode: Int?
  let message: String
  let result: [SubscriptionItem]
  
  // 편의 속성: result를 subscriptions로 접근
  var subscriptions: [SubscriptionItem] {
    return result
  }
}

/// 개별 구독 아이템
struct SubscriptionItem: Codable, Identifiable {
  let id: Int64
  let url: String
  let alias: String
  let isUrgent: Bool
  let keywords: [KeywordItem]
  
  enum CodingKeys: String, CodingKey {
    case id
    case url
    case alias
    case isUrgent
    case keywords
  }
}

/// 키워드 아이템
struct KeywordItem: Codable, Identifiable {
  let id: Int64
  let name: String
}
