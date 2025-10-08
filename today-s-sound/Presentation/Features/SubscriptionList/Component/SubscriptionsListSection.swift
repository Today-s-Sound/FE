//
//  SubscriptionsListSection.swift
//  today-s-sound
//
//  Created by Assistant on 12/19/24.
//

import SwiftUI

struct SubscriptionsListSection: View {
    let subscriptions: [Subscription]
    let colorScheme: ColorScheme

    var body: some View {
        if subscriptions.isEmpty {
            EmptyStateView(message: "구독 중인 페이지가 없어요.", colorScheme: colorScheme)
        } else {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(subscriptions) { subscription in
                        SubscriptionCardView(subscription: subscription, colorScheme: colorScheme)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
    }
}


