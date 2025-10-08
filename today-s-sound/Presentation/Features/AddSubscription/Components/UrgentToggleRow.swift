//
//  UrgentToggleRow.swift
//  today-s-sound
//
//  Created by Assistant on 12/19/24.
//

import SwiftUI

struct UrgentToggleRow: View {
    @Binding var isOn: Bool
    let colorScheme: ColorScheme

    var body: some View {
        HStack {
            Text("긴급 알림으로 설정")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.text(colorScheme))
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding()
    }
}

struct UrgentToggleRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            UrgentToggleRow(isOn: .constant(true), colorScheme: .light)
            UrgentToggleRow(isOn: .constant(false), colorScheme: .dark)
        }
        .padding()
    }
}


