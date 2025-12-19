import Foundation

/// 홈 피드 전용 응답 모델
struct HomeFeedItemResponse: Codable, Identifiable {
  let subscriptionId: Int64
  let alias: String
  let summaryContent: String
  let postUrl: String
  let timeAgo: String
  let isUrgent: Bool

  // SwiftUI ForEach에서 사용할 식별자
  var id: Int64 { subscriptionId }

  enum CodingKeys: String, CodingKey {
    case subscriptionId
    case alias
    case summaryContent
    case postUrl
    case timeAgo
    case isUrgent
  }
}

/// 홈 피드 목록 응답 (APIResponse 형태)
/// 서버가 APIResponse<[HomeFeedItemResponse]> 형태로 응답
typealias HomeFeedResponse = APIResponse<[HomeFeedItemResponse]>

extension HomeFeedResponse {
  // 편의 속성: result를 items로 접근
  var items: [HomeFeedItemResponse] {
    result
  }
}

/// 피드 목록 응답 (페이지네이션 지원)
/// 서버가 APIResponse<[FeedItemResponse]> 형태로 응답
typealias FeedListResponse = APIResponse<[FeedItemResponse]>

extension FeedListResponse {
  // 편의 속성: result를 feeds로 접근
  var feeds: [FeedItemResponse] {
    result
  }
}

/// 개별 피드 아이템
struct FeedItemResponse: Codable, Identifiable {
  let subscriptionId: Int64
  let alias: String
  let summaryTitle: String
  let summaryContent: String
  let postUrl: String
  let timeAgo: String
  let isUrgent: Bool

  // SwiftUI ForEach에서 사용할 식별자
  var id: Int64 { subscriptionId }

  enum CodingKeys: String, CodingKey {
    case subscriptionId
    case alias
    case summaryTitle
    case summaryContent
    case postUrl
    case timeAgo
    case isUrgent
  }
}
