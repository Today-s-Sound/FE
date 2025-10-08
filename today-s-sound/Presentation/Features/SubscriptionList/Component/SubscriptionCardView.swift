//
//  SubscriptionCardView.swift
//  today-s-sound
//
//  Created by Assistant on 12/19/24.
//

import SwiftUI

struct SubscriptionCardView: View {
    let subscription: Subscription
    let colorScheme: ColorScheme

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(subscription.name)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color.text(colorScheme))

                Text(subscription.url)
                    .font(.system(size: 13))
                    .foregroundColor(Color.secondaryText(colorScheme))
                    .lineLimit(1)

                HStack(spacing: 8) {
                    StatusBadge(text: "등록중", colorScheme: colorScheme)
                    StatusBadge(text: "일이삼사", colorScheme: colorScheme)
                }
            }

            Spacer()

            Button(action: {}) {
                Image(systemName: "bell")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondaryBackground(colorScheme))
                .shadow(color: .black5, radius: 4, x: 0, y: 2)
        )
    }
}


