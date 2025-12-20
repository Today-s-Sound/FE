//
//  AlertCardView.swift
//  today-s-sound
//

import SwiftUI

struct AlertCardView: View {
  let alarm: AlarmItem
  let theme: AppTheme
  let isRead: Bool
  let onMarkAsRead: ((AlarmItem) -> Void)?
  @Environment(\.openURL) private var openURL

  init(alarm: AlarmItem, theme: AppTheme, isRead: Bool = false, onMarkAsRead: ((AlarmItem) -> Void)? = nil) {
    self.alarm = alarm
    self.theme = theme
    self.isRead = isRead
    self.onMarkAsRead = onMarkAsRead
  }

  private var cardColor: Color {
    if isRead {
      return Color.gray.opacity(0.6) // 읽음 상태: 회색
    }
    return alarm.isUrgent ? .urgentPink : .primaryGreen
  }

  private var textColor: Color {
    .white
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      // 상단: 아이콘 + 제목 + 읽음 체크
      HStack(alignment: .top, spacing: 12) {
        Image(alarm.isUrgent ? "notice" : "mail")
          .resizable()
          .scaledToFit()
          .frame(width: 48, height: 48)
          .opacity(isRead ? 0.6 : 1.0)
          .accessibilityHidden(true)

        Text(alarm.alias)
          .font(.KoddiExtraBold32)
          .foregroundColor(textColor)
          .multilineTextAlignment(.leading)
          .accessibilityLabel("구독 페이지: \(alarm.alias)")

        Spacer()

        // 읽음 체크 버튼
        if !isRead {
          Button {
            onMarkAsRead?(alarm)
          } label: {
            Image(systemName: "circle")
              .font(.system(size: 28, weight: .medium))
              .foregroundColor(textColor)
          }
          .buttonStyle(.borderless)
          .accessibilityLabel("읽음 표시")
          .accessibilityHint("탭하면 읽음으로 표시합니다")
        } else {
          Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 28, weight: .medium))
            .foregroundColor(textColor)
            .accessibilityLabel("읽음 표시됨")
        }
      }

      // 중간: 요약 내용
      Text(alarm.summaryContent)
        .font(.KoddiRegular20)
        .foregroundColor(textColor)
        .multilineTextAlignment(.leading)
        .accessibilityLabel("내용: \(alarm.summaryContent)")

      // 하단: 시간 + 원문 보기 버튼
      HStack {
        HStack(spacing: 8) {
          Text(alarm.timeAgo)
            .font(.KoddiRegular16)
            .foregroundColor(textColor)

          if isRead {
            Text("· 읽음")
              .font(.KoddiBold14)
              .foregroundColor(textColor.opacity(0.8))
          }
        }
        .accessibilityLabel("작성 시간: \(alarm.timeAgo)\(isRead ? ", 읽음" : "")")

        Spacer()

        // 원문 보기 버튼
        Button {
          guard let url = URL(string: alarm.postUrl) else { return }
          openURL(url)
        } label: {
          HStack(spacing: 4) {
            Text("원문 보기")
              .font(.KoddiBold14)
            Image(systemName: "arrow.up.right")
              .font(.system(size: 12, weight: .bold))
          }
          .foregroundColor(textColor)
          .padding(.horizontal, 12)
          .padding(.vertical, 6)
          .background(
            Capsule()
              .fill(Color.white.opacity(0.2))
          )
        }
        .buttonStyle(.borderless)
        .accessibilityLabel("원문 보기 버튼")
        .accessibilityHint("탭하면 Safari에서 원문 페이지를 엽니다")
      }
    }
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: 10)
        .fill(cardColor)
    )
    .accessibilityElement(children: .contain)
  }
}

struct AlertCardView_Previews: PreviewProvider {
  private static let sampleAlarms: [AlarmItem] = [
    AlarmItem(
      subscriptionId: 1,
      summaryId: 101,
      alias: "동국대 SW 융합교육원",
      summaryContent: "동국대학교 SW 융합교육원에서 새로운 교육 프로그램 공지가 등록되었습니다. 마감 기한을 꼭 확인해주세요.",
      postUrl: "https://www.dongguk.edu/article/GENERALNOTICES/list",
      timeAgo: "5분 전",
      isUrgent: true
    ),
    AlarmItem(
      subscriptionId: 2,
      summaryId: 102,
      alias: "오늘의 소리 팀 공지",
      summaryContent: "오늘의 소리 앱이 업데이트되었습니다. 접근성 관련 보이스오버 개선과 버그 수정이 포함되어 있습니다.",
      postUrl: "https://techblog.woowahan.com/",
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
