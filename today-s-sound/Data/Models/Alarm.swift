//
//  Alarm.swift
//  today-s-sound
//

import Foundation

/// 최근 알림 목록 응답
/// 서버가 [RecentAlarmResponse] 배열을 내려준다고 했으니까 그대로 [AlarmItem]으로 매핑
typealias AlarmListResponse = [AlarmItem]

/// 개별 알림 아이템 (RecentAlarmResponse)
struct AlarmItem: Codable, Identifiable {
  let subscriptionId: Int64 // 구독 ID (알림 ID 역할)
  let alias: String // 구독 별칭
  let summaryContent: String // 요약 내용
  let timeAgo: String // "~분 전" 같은 상대 시간
  let isUrgent: Bool // 긴급 여부

  // SwiftUI ForEach에서 사용할 식별자
  var id: Int64 { subscriptionId }

  enum CodingKeys: String, CodingKey {
    case subscriptionId
    case alias
    case summaryContent
    case timeAgo
    case isUrgent
  }

  // Preview 등에서 쓰기 위한 커스텀 init
  init(
    subscriptionId: Int64,
    alias: String,
    summaryContent: String,
    timeAgo: String,
    isUrgent: Bool
  ) {
    self.subscriptionId = subscriptionId
    self.alias = alias
    self.summaryContent = summaryContent
    self.timeAgo = timeAgo
    self.isUrgent = isUrgent
  }
}
