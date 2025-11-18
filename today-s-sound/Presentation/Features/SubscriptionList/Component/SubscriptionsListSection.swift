//
//  SubscriptionsListSection.swift
//  today-s-sound
//
//  Created by Assistant on 12/19/24.
//

import SwiftUI

struct SubscriptionsListSection: View {
  let subscriptions: [SubscriptionItem]
  let colorScheme: ColorScheme
  let onLoadMore: (SubscriptionItem) -> Void
  let onDelete: (SubscriptionItem) -> Void
  let isLoadingMore: Bool

  var body: some View {
    if subscriptions.isEmpty {
      EmptyStateView(message: "구독 중인 페이지가 없어요.", colorScheme: colorScheme)
    } else {
      List {
        ForEach(subscriptions) { subscription in
          SubscriptionCardView(subscription: subscription, colorScheme: colorScheme)
            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
              Button(role: .destructive) {
                onDelete(subscription)
              } label: {
                Label("삭제", systemImage: "trash")
              }
            }
            .onAppear {
              // 마지막에서 5번째 아이템이 보일 때만 트리거
              if let lastIndex = subscriptions.indices.last,
                 let currentIndex = subscriptions.firstIndex(where: { $0.id == subscription.id }),
                 currentIndex >= lastIndex - 4
              { // 마지막에서 5번째부터
                onLoadMore(subscription)
              }
            }
        }

        // 더 불러오는 중 인디케이터
        if isLoadingMore {
          HStack {
            Spacer()
            ProgressView()
              .padding()
            Spacer()
          }
          .listRowInsets(EdgeInsets())
          .listRowBackground(Color.clear)
        }
      }
      .listStyle(.plain)
      .scrollContentBackground(.hidden)
    }
  }
}

struct SubscriptionsListSection_Previews: PreviewProvider {
  private static let sampleSubscriptions: [SubscriptionItem] = [
    SubscriptionItem(
      id: 1,
      url: "https://newsroom.apple.com",
      alias: "애플 뉴스룸",
      isUrgent: false,
      keywords: [
        KeywordItem(id: 1, name: "아이폰"),
        KeywordItem(id: 2, name: "애플워치")
      ]
    ),
    SubscriptionItem(
      id: 2,
      url: "https://blog.naver.com/accessibility",
      alias: "접근성 블로그",
      isUrgent: true,
      keywords: [
        KeywordItem(id: 3, name: "시각"),
        KeywordItem(id: 4, name: "보이스오버"),
        KeywordItem(id: 5, name: "스크린리더")
      ]
    )
  ]

  static var previews: some View {
    Group {
      SubscriptionsListSection(
        subscriptions: sampleSubscriptions,
        colorScheme: .light,
        onLoadMore: { _ in },
        onDelete: { _ in },
        isLoadingMore: true
      )
      .previewDisplayName("List - Light")

      SubscriptionsListSection(
        subscriptions: [],
        colorScheme: .dark,
        onLoadMore: { _ in },
        onDelete: { _ in },
        isLoadingMore: false
      )
      .previewDisplayName("Empty - Dark")
      .background(Color.black)
    }
  }
}
