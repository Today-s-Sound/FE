import Foundation

// MARK: - Subscription Request Models

/// 구독 생성 요청
struct CreateSubscriptionRequest: Codable {
  let urlId: Int64
  let keywordIds: [Int64]
  let alias: String?
  let isUrgent: Bool
}

// MARK: - Subscription Response Models

/// 구독 목록 응답
typealias SubscriptionListResponse = APIResponse<[SubscriptionItem]>

/// 구독 생성 결과
struct CreateSubscriptionResult: Codable {
  let subscriptionId: Int64
}

/// 구독 생성 응답
typealias CreateSubscriptionResponse = APIResponse<CreateSubscriptionResult>

extension CreateSubscriptionResponse {
  // 편의 속성: result의 subscriptionId에 직접 접근
  var subscriptionId: Int64 {
    result.subscriptionId
  }
}

/// 구독 삭제 응답
struct DeleteSubscriptionResponse: Codable {
  let message: String
}

/// 알람 차단/해제 응답
struct AlarmBlockResponse: Codable {
  let message: String?
}

extension SubscriptionListResponse {
  // 편의 속성: result를 subscriptions로 접근
  var subscriptions: [SubscriptionItem] {
    result
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

struct KeywordItem: Codable, Identifiable {
  let id: Int64
  let name: String
}
