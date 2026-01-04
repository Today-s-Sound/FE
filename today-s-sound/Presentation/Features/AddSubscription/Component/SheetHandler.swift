//
//  SheetHandler.swift
//  today-s-sound
//
//  Reused as a simple sheet handle bar.
//

import SwiftUI

/// 시트 상단에 보이는 작은 핸들 바
struct SheetHandleBar: View {
  let theme: AppTheme
  let onTap: (() -> Void)?

  init(theme: AppTheme, onTap: (() -> Void)? = nil) {
    self.theme = theme
    self.onTap = onTap
  }

  var body: some View {
    VStack(spacing: 8) {
      // 터치 영역을 넓히기 위한 투명한 영역
      ZStack {
        // 실제 핸들 바
        Capsule()
          .fill(Color.secondaryText(theme).opacity(0.3))
          .frame(width: 80, height: 5)
          .padding(.top, 8)

        // 넓은 터치 영역 (투명)
        Color.clear
          .frame(height: 44) // 최소 터치 영역 확보
          .contentShape(Rectangle())
          .onTapGesture {
            onTap?()
          }
      }
      .accessibilityHidden(true)

      // 핸들 바와 실제 콘텐츠 사이 살짝 여백
      Spacer()
        .frame(height: 16)
    }
  }
}

struct SheetHandleBar_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      SheetHandleBar(theme: .normal)
      SheetHandleBar(theme: .highContrast)
    }
    .background(Color.background(.normal))
  }
}
