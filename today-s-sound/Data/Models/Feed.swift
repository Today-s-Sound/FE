import Foundation

/// 홈 피드 목록 응답 (페이지네이션 없음)
/// 서버가 배열을 직접 내려주므로 [FeedItemResponse]로 매핑
typealias HomeFeedResponse = [FeedItemResponse]

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
  let summaryContent: String
  let url: String
  let timeAgo: String
  let isUrgent: Bool

  // SwiftUI ForEach에서 사용할 식별자
  var id: Int64 { subscriptionId }

  enum CodingKeys: String, CodingKey {
    case subscriptionId
    case alias
    case summaryContent
    case url
    case timeAgo
    case isUrgent
  }
}

