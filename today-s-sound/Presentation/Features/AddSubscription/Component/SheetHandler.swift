//
//  SheetHandler.swift
//  today-s-sound
//
//  Reused as a simple sheet handle bar.
//

import SwiftUI

/// 시트 상단에 보이는 작은 핸들 바
struct SheetHandleBar: View {
  let colorScheme: ColorScheme

  var body: some View {
    VStack(spacing: 8) {
      Capsule()
        .fill(Color.secondaryText(colorScheme).opacity(0.3))
        .frame(width: 80, height: 5)
        .padding(.top, 8)

      // 핸들 바와 실제 콘텐츠 사이 살짝 여백
      Spacer()
        .frame(height: 16)
    }
  }
}

struct SheetHandleBar_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      SheetHandleBar(colorScheme: .light)
      SheetHandleBar(colorScheme: .dark)
    }
    .background(Color.background(.light))
  }
}
