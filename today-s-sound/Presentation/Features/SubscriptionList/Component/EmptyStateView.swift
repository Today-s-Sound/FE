//
//  EmptyStateView.swift
//  today-s-sound
//
//  Created by Assistant on 12/19/24.
//

import SwiftUI

struct EmptyStateView: View {
    let message: String
    let colorScheme: ColorScheme

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40, weight: .regular))
                .foregroundColor(Color.secondaryText(colorScheme))
            Text(message)
                .foregroundColor(Color.secondaryText(colorScheme))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


