//
//  AlertCardView.swift
//  today-s-sound
//

import SwiftUI

struct AlertCardView: View {
  let alarm: AlarmItem
  let theme: AppTheme

  private var cardColor: Color {
    alarm.isUrgent ? .urgentPink : .primaryGreen
  }

  private var textColor: Color {
    .white
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      // 상단: 아이콘 + 제목
      HStack(alignment: .top, spacing: 12) {
        Image(alarm.isUrgent ? "notice" : "mail")
          .resizable()
          .scaledToFit()
          .frame(width: 48, height: 48)
          .accessibilityHidden(true)

        Text(alarm.alias)
          .font(.KoddiExtraBold32)
          .foregroundColor(textColor)
          .multilineTextAlignment(.leading)
          .accessibilityLabel("구독 페이지: \(alarm.alias)")

        Spacer()
      }

      // 중간: 요약 내용
      Text(alarm.summaryContent)
        .font(.KoddiRegular20)
        .foregroundColor(textColor)
        .multilineTextAlignment(.leading)
        .accessibilityLabel("내용: \(alarm.summaryContent)")

      // 하단: 시간
      Text(alarm.timeAgo)
        .font(.KoddiRegular16)
        .foregroundColor(textColor)
        .accessibilityLabel("작성 시간: \(alarm.timeAgo)")
    }
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: 10)
        .fill(cardColor)
    )
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(alarm.isUrgent ? "긴급 " : "일반 ")알림, \(alarm.alias), \(alarm.summaryContent), \(alarm.timeAgo)")
  }
}

struct AlertCardView_Previews: PreviewProvider {
  private static let sampleAlarms: [AlarmItem] = [
    AlarmItem(
      subscriptionId: 1,
      alias: "동국대 SW 융합교육원",
      summaryContent: "동국대학교 SW 융합교육원에서 새로운 교육 프로그램 공지가 등록되었습니다. 마감 기한을 꼭 확인해주세요.",
      url: "https://www.dongguk.edu/article/GENERALNOTICES/list",
      timeAgo: "5분 전",
      isUrgent: true
    ),
    AlarmItem(
      subscriptionId: 2,
      alias: "오늘의 소리 팀 공지",
      summaryContent: "오늘의 소리 앱이 업데이트되었습니다. 접근성 관련 보이스오버 개선과 버그 수정이 포함되어 있습니다.",
      url: "https://techblog.woowahan.com/",
      timeAgo: "10분 전",
      isUrgent: false
    )
  ]

  static var previews: some View {
    Group {
      ForEach(sampleAlarms) { alarm in
        AlertCardView(alarm: alarm, theme: .normal)
          .padding()
          .previewDisplayName("Card Normal - \(alarm.alias)")
      }

      ForEach(sampleAlarms) { alarm in
        AlertCardView(alarm: alarm, theme: .highContrast)
          .padding()
          .background(Color.black)
          .previewDisplayName("Card High Contrast - \(alarm.alias)")
      }
    }
    .previewLayout(.sizeThatFits)
  }
}
