import Foundation

struct FeedItem: Identifiable, Hashable {
  let id: UUID
  let alias: String
  let summary: String
  let summaryTitle: String
  let publishedAt: Date
  let timeAgo: String // 서버에서 받은 시간 문자열 ("2시간 전" 등)

  /// "1시간 전", "3분 전" 같은 상대 시간 텍스트
  var relativeTimeText: String {
    let formatter = RelativeDateTimeFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.unitsStyle = .full
    return formatter.localizedString(for: publishedAt, relativeTo: Date())
  }

  init(
    id: UUID = UUID(),
    alias: String,
    summary: String,
    summaryTitle: String,
    publishedAt: Date,
    timeAgo: String = ""
  ) {
    self.id = id
    self.alias = alias
    self.summary = summary
    self.summaryTitle = summaryTitle
    self.publishedAt = publishedAt
    self.timeAgo = timeAgo
  }
}
