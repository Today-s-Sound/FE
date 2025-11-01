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
  let isLoadingMore: Bool

  var body: some View {
    if subscriptions.isEmpty {
      EmptyStateView(message: "구독 중인 페이지가 없어요.", colorScheme: colorScheme)
    } else {
      ScrollView {
        VStack(spacing: 12) {
          ForEach(subscriptions) { subscription in
            SubscriptionCardView(subscription: subscription, colorScheme: colorScheme)
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
          }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
      }
    }
  }
}
