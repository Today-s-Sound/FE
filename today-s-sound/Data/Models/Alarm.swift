//
//  Alarm.swift
//  today-s-sound
//
//  Created by Assistant
//

import Foundation

// MARK: - Alarm Response Models

/// 알림 목록 응답
typealias AlarmListResponse = APIResponse<[AlarmItem]>

extension AlarmListResponse {
  // 편의 속성: result를 alarms로 접근
  var alarms: [AlarmItem] {
    result
  }
}

/// 개별 알림 아이템
struct AlarmItem: Codable, Identifiable {
  let alias: String
  let timeAgo: String
  let summaries: [SummaryItem]
  let isUrgent: Bool?

  // Identifiable을 위한 id (alias를 고유 식별자로 사용)
  var id: String { alias }

  enum CodingKeys: String, CodingKey {
    case alias
    case timeAgo
    case summaries
    case isUrgent
  }

  // 디코딩 시 isUrgent가 없으면 nil로 설정
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    alias = try container.decode(String.self, forKey: .alias)
    timeAgo = try container.decode(String.self, forKey: .timeAgo)
    summaries = try container.decode([SummaryItem].self, forKey: .summaries)
    isUrgent = try container.decodeIfPresent(Bool.self, forKey: .isUrgent)
  }

  // 인코딩
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(alias, forKey: .alias)
    try container.encode(timeAgo, forKey: .timeAgo)
    try container.encode(summaries, forKey: .summaries)
    try container.encodeIfPresent(isUrgent, forKey: .isUrgent)
  }

  // 수동 초기화 (Preview 등에서 사용)
  init(alias: String, timeAgo: String, summaries: [SummaryItem], isUrgent: Bool? = nil) {
    self.alias = alias
    self.timeAgo = timeAgo
    self.summaries = summaries
    self.isUrgent = isUrgent
  }
}

/// 요약 아이템
struct SummaryItem: Codable, Identifiable {
  let id: Int64
  let summary: String
  let updatedAt: String // ISO8601 문자열

  // Date로 변환하는 편의 속성
  var updatedDate: Date? {
    let formatter = ISO8601DateFormatter()
    return formatter.date(from: updatedAt)
  }
}
