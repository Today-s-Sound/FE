//
//  AlertCardView.swift
//  today-s-sound
//

import SwiftUI

struct AlertCardView: View {
  let alarm: AlarmItem
  let theme: AppTheme
  let onDelete: ((AlarmItem) -> Void)?

  init(alarm: AlarmItem, theme: AppTheme, onDelete: ((AlarmItem) -> Void)? = nil) {
    self.alarm = alarm
    self.theme = theme
    self.onDelete = onDelete
  }

  private var cardColor: Color {
    alarm.isKeywordMatched ? .urgentPink : .primaryGreen
  }

  private var textColor: Color { .white }

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      // 상단: 아이콘 + 제목 + (오른쪽 상단 삭제 버튼)
      HStack(alignment: .top, spacing: 12) {
        Image(alarm.isKeywordMatched ? "notice" : "mail")
          .resizable()
          .scaledToFit()
          .frame(width: 48, height: 48)
          .accessibilityHidden(true)

        Text(alarm.alias)
          .font(.KoddiExtraBold32)
          .foregroundColor(textColor)
          .multilineTextAlignment(.leading)
          .accessibilityLabel(alarm.isKeywordMatched ? "키워드 매칭 알림 " + alarm.alias : alarm.alias)
          .accessibilityAddTraits(.isHeader)

        Spacer()

        // ✅ 삭제 버튼: 예전 읽음 체크 자리(오른쪽 상단), 아이콘만, 투명 배경
        Button {
          onDelete?(alarm)
        } label: {
          Image(systemName: "trash")
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(textColor)
            .frame(width: 36, height: 36)
            .background(
              Circle().fill(Color.white.opacity(0.18))
            )
            .contentShape(Circle())
        }
        .buttonStyle(.borderless)
        .frame(width: 44, height: 44)
        .contentShape(Rectangle())
        .accessibilityLabel("삭제")
        .accessibilityHint("이 알림을 삭제합니다")
      }

      // 본문
      Text(alarm.summaryContent)
        .font(.KoddiRegular20)
        .foregroundColor(textColor)
        .multilineTextAlignment(.leading)

      // 하단: 시간 + 원문 보기(Link)
      HStack {
        Text(alarm.timeAgo)
          .font(.KoddiRegular16)
          .foregroundColor(textColor)

        Spacer()

        // ✅ 원문 보기: Link (VoiceOver가 “링크”로 읽음)
        if let url = URL(string: alarm.postUrl) {
          Link(destination: url) {
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
              Capsule().fill(Color.white.opacity(0.2))
            )
          }
          .accessibilityLabel("원문 보기")
          .accessibilityHint("탭하면 Safari에서 원문 페이지를 엽니다")
          .accessibilityRemoveTraits(.isButton)
          .frame(minHeight: 44)
        }
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
