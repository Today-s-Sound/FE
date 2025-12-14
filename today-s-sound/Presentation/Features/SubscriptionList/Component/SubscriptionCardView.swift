//
//  SubscriptionCardView.swift
//  today-s-sound
//
//  Created by Assistant on 12/19/24.
//

import SwiftUI

struct SubscriptionCardView: View {
  let subscription: SubscriptionItem
  let colorScheme: AppTheme
  var onToggleAlarm: ((SubscriptionItem) -> Void)?

  var body: some View {
    HStack(spacing: 12) {
      VStack(alignment: .leading, spacing: 8) {
        // 구독 이름 (alias)
        Text(subscription.alias)
          .font(.KoddiBold20)
          .foregroundColor(Color.primaryGrey)
          .accessibilityLabel("구독 페이지 이름: \(subscription.alias)")

        // URL
        Text(subscription.url)
          .font(.KoddiRegular16)
          .foregroundColor(Color.primaryGrey)
          .lineLimit(1)
          .accessibilityLabel("주소: \(subscription.url)")

        // 키워드 배지들
        if !subscription.keywords.isEmpty {
          HStack(spacing: 8) {
            ForEach(subscription.keywords.prefix(3)) { keyword in
              StatusBadge(text: keyword.name, colorScheme: colorScheme)
                .accessibilityLabel("설정 키워드: \(keyword.name)")
            }

            // 더 많은 키워드가 있으면 "+" 표시
            if subscription.keywords.count > 3 {
              StatusBadge(
                text: "+\(subscription.keywords.count - 3)",
                colorScheme: colorScheme
              )
              .accessibilityLabel("그외 \(subscription.keywords.count - 3)개")
            }
          }
        }
      }

      Spacer()

      // 긴급 알림 아이콘
      Button(action: {
        onToggleAlarm?(subscription)
      }, label: {
        Image(subscription.isUrgent ? "Bell" : "Bell off")
          .frame(width: 40, height: 40)
          .accessibilityLabel(subscription.isUrgent ? "페이지 알림 설정됨" : "페이지 알림 해제됨")
      })
      .accessibilityHint("탭하여 이 페이지의 구독 알림 설정을 변경합니다")
    }
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(Color.greyBackground)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color.borderGrey, lineWidth: 1)
        )
    )
  }
}

struct SubscriptionCardView_Previews: PreviewProvider {
  private static let sampleSubscription = SubscriptionItem(
    id: 1,
    url: "https://newsroom.apple.com",
    alias: "애플 뉴스룸",
    isUrgent: false,
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
        colorScheme: .normal
      )
      .padding()
      .previewDisplayName("Normal")

      SubscriptionCardView(
        subscription: sampleSubscription,
        colorScheme: .highContrast
      )
      .padding()
      .previewDisplayName("High Contrast")
      .background(Color.black)
    }
    .previewLayout(.sizeThatFits)
  }
}
