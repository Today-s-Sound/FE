//
//  HeaderBar.swift
//  today-s-sound
//
//  Created by Assistant on 12/19/24.
//

import SwiftUI

struct HeaderBar: View {
    let colorScheme: ColorScheme
    let onClose: () -> Void

    var body: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(Color.text(colorScheme))
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
}

struct HeaderBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            HeaderBar(colorScheme: .light, onClose: {})
            HeaderBar(colorScheme: .dark, onClose: {})
        }
    }
}


