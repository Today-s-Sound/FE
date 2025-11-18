//
//  SubscriptionCardView.swift
//  today-s-sound
//
//  Created by Assistant on 12/19/24.
//

import SwiftUI

struct SubscriptionCardView: View {
  let subscription: SubscriptionItem
  let colorScheme: ColorScheme

  var body: some View {
    HStack(spacing: 12) {
      VStack(alignment: .leading, spacing: 8) {
        // 구독 이름 (alias)
        Text(subscription.alias)
          .font(.system(size: 20, weight: .semibold))
          .foregroundColor(Color.text(colorScheme))

        // URL
        Text(subscription.url)
          .font(.system(size: 13))
          .foregroundColor(Color.secondaryText(colorScheme))
          .lineLimit(1)

        // 키워드 배지들
        if !subscription.keywords.isEmpty {
          HStack(spacing: 8) {
            ForEach(subscription.keywords.prefix(3)) { keyword in
              StatusBadge(text: keyword.name, colorScheme: colorScheme)
            }

            // 더 많은 키워드가 있으면 "+" 표시
            if subscription.keywords.count > 3 {
              StatusBadge(
                text: "+\(subscription.keywords.count - 3)",
                colorScheme: colorScheme
              )
            }
          }
        }
      }

      Spacer()

      // 긴급 알림 아이콘
      Button(action: {}, label: {
        Image(systemName: subscription.isUrgent ? "bell.fill" : "bell")
          .font(.system(size: 40))
          .foregroundColor(subscription.isUrgent ? .red : .green)
      })
    }
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.secondaryBackground(colorScheme))
        .shadow(color: .black5, radius: 4, x: 0, y: 2)
    )
  }
}

struct SubscriptionCardView_Previews: PreviewProvider {
  private static let sampleSubscription = SubscriptionItem(
    id: 1,
    url: "https://newsroom.apple.com",
    alias: "애플 뉴스룸",
    isUrgent: true,
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
        colorScheme: .light
      )
      .padding()
      .previewDisplayName("Light")

      SubscriptionCardView(
        subscription: sampleSubscription,
        colorScheme: .dark
      )
      .padding()
      .previewDisplayName("Dark")
      .background(Color.black)
    }
    .previewLayout(.sizeThatFits)
  }
}
