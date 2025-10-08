//
//  KeywordBadge.swift
//  today-s-sound
//
//  Created by Assistant on 12/19/24.
//

import SwiftUI

struct KeywordBadge: View {
    let text: String
    let colorScheme: ColorScheme

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(Color.text(colorScheme))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.primaryGreen20)
            )
    }
}

struct KeywordBadge_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            KeywordBadge(text: "장학금", colorScheme: .light)
            KeywordBadge(text: "교직부공지사항", colorScheme: .dark)
        }
        .padding()
    }
}
