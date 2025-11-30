import Foundation

struct FeedItem: Identifiable, Hashable {
  let id: UUID
  let title: String
  let summary: String
  let source: String
  let publishedAt: Date

  var relativeTimeText: String {
    let formatter = RelativeDateTimeFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.unitsStyle = .full
    return formatter.localizedString(for: publishedAt, relativeTo: Date())
  }
}

enum FeedSampleData {
  static let items: [FeedItem] = [
    FeedItem(
      id: UUID(),
      title: "교육부, 시각장애 학생을 위한 AI 오디오 교재 배포",
      summary: "전국 특수학교 대상으로 접근성 강화된 음성 교재를 순차 배포합니다.",
      source: "교육부 보도자료",
      publishedAt: Date().addingTimeInterval(-3600)
    ),
    FeedItem(
      id: UUID(),
      title: "서울시청, 공공 서비스 음성 지원 확대 발표",
      summary: "민원 앱 내 보이스오버 전용 모드를 도입해 정보 접근성을 높입니다.",
      source: "서울시청 뉴스룸",
      publishedAt: Date().addingTimeInterval(-8400)
    ),
    FeedItem(
      id: UUID(),
      title: "오늘의 소리 사용자 인터뷰",
      summary: "베타 사용자들이 직접 전해준 알림 읽기 경험과 개선 아이디어를 소개합니다.",
      source: "오늘의 소리 팀",
      publishedAt: Date().addingTimeInterval(-18000)
    )
  ]
}
