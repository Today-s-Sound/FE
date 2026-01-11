//
//  SubscriptionCardView.swift
//  today-s-sound
//
//  Created by Assistant on 12/19/24.
//

import SwiftUI

struct SubscriptionCardView: View {
  let subscription: SubscriptionItem
  let theme: AppTheme
  var onToggleAlarm: ((SubscriptionItem) -> Void)?

  private var resolvedTextColor: Color {
    theme == .highContrast ? .white : Color.primaryGrey
  }

  private var resolvedCardBackgroundColor: Color {
    theme == .highContrast ? Color(white: 0.12) : Color.greyBackground
  }

  private var resolvedBorderColor: Color {
    theme == .highContrast ? Color(white: 0.25) : Color.borderGrey
  }

  // 접근성용 문구: 구독 이름 + 키워드(최대 3개 + 나머지 개수)
  private var keywordsA11yText: String {
    if subscription.keywords.isEmpty { return "설정 키워드 없음" }

    let firstThree = subscription.keywords.prefix(3).map(\.name)
    var result = "설정 키워드: " + firstThree.joined(separator: ", ")

    if subscription.keywords.count > 3 {
      result += ", 그 외 \(subscription.keywords.count - 3)개"
    }
    return result
  }

  private var infoA11yLabel: String {
    "\(subscription.alias). \(keywordsA11yText)"
  }

  var body: some View {
    HStack(spacing: 12) {
      // 구독 이름 + 키워드(한 번에 읽기)
      VStack(alignment: .leading, spacing: 8) {
        // 구독 이름 (alias)
        Text(subscription.alias)
          .font(.KoddiBold20)
          .foregroundColor(resolvedTextColor)

        // URL (시각적으로는 유지, 접근성에서는 숨김)
        Text(subscription.url)
          .font(.KoddiRegular16)
          .foregroundColor(resolvedTextColor)
          .lineLimit(1)
          .accessibilityHidden(true)

        // 키워드 배지들 (시각적으로는 유지, 접근성에서는 컨테이너가 대표)
        if !subscription.keywords.isEmpty {
          HStack(spacing: 8) {
            ForEach(subscription.keywords.prefix(3)) { keyword in
              StatusBadge(text: keyword.name, theme: theme)
                .accessibilityHidden(true)
            }

            if subscription.keywords.count > 3 {
              StatusBadge(
                text: "+\(subscription.keywords.count - 3)",
                theme: theme
              )
              .accessibilityHidden(true)
            }
          }
        }
      }
      // 이 VStack 자체를 하나의 접근성 요소로 만들고(자식들은 읽지 않음)
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(infoA11yLabel)

      Spacer()

      // 알림 토글 버튼
      Button {
        onToggleAlarm?(subscription)
      } label: {
        Image(subscription.isAlarmEnabled ? "Bell" : "Bell off")
          .resizable()
          .scaledToFit()
          .frame(width: 44, height: 44)
          .frame(width: 44, height: 44)
          .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
      .accessibilityLabel("알림")
      .accessibilityValue(subscription.isAlarmEnabled ? "켜짐" : "꺼짐")
    }
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(resolvedCardBackgroundColor)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(resolvedBorderColor, lineWidth: 1)
        )
    )
  }
}

struct SubscriptionCardView_Previews: PreviewProvider {
  private static let sampleSubscription = SubscriptionItem(
    id: 1,
    url: "https://newsroom.apple.com",
    alias: "애플 뉴스룸",
    isAlarmEnabled: true,
    keywords: [
      KeywordItem(id: 1, name: "아이폰"),
      KeywordItem(id: 2, name: "접근성"),
      KeywordItem(id: 3, name: "애플워치"),
      KeywordItem(id: 4, name: "iOS")
    ]
  )

  static var previews: some View {
    Group {
      SubscriptionCardView(
        subscription: sampleSubscription,
        theme: .normal
      )
      .padding()
      .previewDisplayName("Normal")
      .environmentObject(AppThemeManager())

      SubscriptionCardView(
        subscription: sampleSubscription,
        theme: .highContrast
      )
      .padding()
      .previewDisplayName("High Contrast")
      .background(Color.black)
      .environmentObject(AppThemeManager())
    }
    .previewLayout(.sizeThatFits)
  }
}
