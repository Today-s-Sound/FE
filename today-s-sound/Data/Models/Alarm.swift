//
//  Alarm.swift
//  today-s-sound
//

import Foundation

/// 최근 알림 목록 응답
/// 서버가 APIResponse<[AlarmItem]> 형태로 응답
typealias AlarmListResponse = APIResponse<[AlarmItem]>

extension AlarmListResponse {
  // 편의 속성: result를 alarms로 접근
  var alarms: [AlarmItem] {
    result
  }
}

/// 개별 알림 아이템 (RecentAlarmResponse)
struct AlarmItem: Codable, Identifiable {
  let subscriptionId: Int64 // 구독 ID
  let summaryId: Int64 // 요약 ID
  let alias: String // 구독 별칭
  let summaryContent: String // 요약 내용
  let postUrl: String // 게시글 URL
  let timeAgo: String // "~분 전" 같은 상대 시간
  let isKeywordMatched: Bool // 키워드 매칭 여부

  // SwiftUI ForEach에서 사용할 식별자
  var id: Int64 { summaryId }

  enum CodingKeys: String, CodingKey {
    case subscriptionId
    case summaryId
    case alias
    case summaryContent
    case postUrl
    case timeAgo
    case isKeywordMatched = "is_keyword_matched"
  }

  // Preview 등에서 쓰기 위한 커스텀 init
  init(
    subscriptionId: Int64,
    summaryId: Int64,
    alias: String,
    summaryContent: String,
    postUrl: String,
    timeAgo: String,
    isKeywordMatched: Bool = false
  ) {
    self.subscriptionId = subscriptionId
    self.summaryId = summaryId
    self.alias = alias
    self.summaryContent = summaryContent
    self.postUrl = postUrl
    self.timeAgo = timeAgo
    self.isKeywordMatched = isKeywordMatched
  }
}
