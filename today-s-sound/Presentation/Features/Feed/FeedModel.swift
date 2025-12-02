import Foundation

struct FeedItem: Identifiable, Hashable {
  let id: UUID
  let alias: String
  let summary: String
  let source: String
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
    source: String,
    publishedAt: Date,
    timeAgo: String = ""
  ) {
    self.id = id
    self.alias = alias
    self.summary = summary
    self.source = source
    self.publishedAt = publishedAt
    self.timeAgo = timeAgo
  }
}

enum FeedSampleData {
  /// 스크롤 테스트용 데모 데이터 (여러 사이트 섞어서 충분히 길게)
  static let items: [FeedItem] = [
    FeedItem(
      alias: "교육부, 시각장애 학생을 위한 AI 오디오 교재 배포",
      summary: "전국 특수학교를 대상으로 접근성 강화 음성 교재를 순차적으로 배포합니다.",
      source: "교육부 보도자료",
      publishedAt: Date().addingTimeInterval(-60 * 20) // 20분 전
    ),
    FeedItem(
      alias: "서울시청, 공공 서비스 음성 지원 확대 발표",
      summary: "서울시는 민원 앱에 보이스오버 전용 모드를 도입해 정보 접근성을 높인다고 밝혔습니다.",
      source: "서울시청 뉴스룸",
      publishedAt: Date().addingTimeInterval(-60 * 60) // 1시간 전
    ),
    FeedItem(
      alias: "오늘의 소리 베타 사용자 인터뷰",
      summary: "베타 사용자들이 직접 전한 알림 읽기 경험과 개선 아이디어를 정리했습니다.",
      source: "오늘의 소리 팀",
      publishedAt: Date().addingTimeInterval(-60 * 60 * 2) // 2시간 전
    ),
    FeedItem(
      alias: "접근성 블로그: iOS 18 보이스오버 변경점 정리",
      summary: "새 버전에서 달라진 제스처와 읽기 옵션을 한 번에 확인해 보세요.",
      source: "접근성 블로그",
      publishedAt: Date().addingTimeInterval(-60 * 60 * 3) // 3시간 전
    ),
    FeedItem(
      alias: "접근성 블로그: 시각장애인을 위한 키보드 단축키 모음",
      summary: "웹 브라우저, 문서 편집기, 메신저 앱에서 유용한 단축키를 정리했습니다.",
      source: "접근성 블로그",
      publishedAt: Date().addingTimeInterval(-60 * 60 * 5) // 5시간 전
    ),
    FeedItem(
      alias: "서울시청, 버스 정류장 음성 안내 고도화",
      summary: "버스 도착 정보에 노선 혼잡도와 환승 정보까지 음성으로 추가 안내합니다.",
      source: "서울시청 뉴스룸",
      publishedAt: Date().addingTimeInterval(-60 * 60 * 7) // 7시간 전
    ),
    FeedItem(
      alias: "교육부, 대학 온라인 강의 자막·음성 안내 의무화 추진",
      summary: "강의 동영상에 자막과 음성 설명을 의무화하는 지침을 마련 중입니다.",
      source: "교육부 보도자료",
      publishedAt: Date().addingTimeInterval(-60 * 60 * 9) // 9시간 전
    ),
    FeedItem(
      alias: "오늘의 소리: 이번 주 서비스 업데이트 안내",
      summary: "알림 필터 기능과 음성 재생 속도 조절 기능이 추가되었습니다.",
      source: "오늘의 소리 팀",
      publishedAt: Date().addingTimeInterval(-60 * 60 * 12) // 12시간 전
    ),
    FeedItem(
      alias: "오늘의 소리: 새로 구독 가능한 웹사이트 소개",
      summary: "시각장애인 관련 단체, 공공기관, 접근성 블로그 등 5개 웹사이트를 새로 추가했습니다.",
      source: "오늘의 소리 팀",
      publishedAt: Date().addingTimeInterval(-60 * 60 * 24) // 1일 전
    ),
    FeedItem(
      alias: "접근성 블로그: 화면 낭독기와 함께 쓰기 좋은 브라우저 설정",
      summary: "페이지 자동 스크롤, 탭 이동, 포커스 표시 옵션을 함께 조정해 보세요.",
      source: "접근성 블로그",
      publishedAt: Date().addingTimeInterval(-60 * 60 * 30) // 1일 6시간 전
    )
  ]
}
