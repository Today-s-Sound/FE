//
//  AddSubscriptionButton.swift
//  today-s-sound
//
//  공통 액션 버튼 컴포넌트
//

import SwiftUI

struct AddSubscriptionButton: View {
  /// 버튼에 표시할 텍스트 (예: "등록 승인 요청", "저장하기")
  let title: String

  /// 컬러 스킴 (라이트/다크에 따라 글자색만 바뀜)
  let colorScheme: ColorScheme

  /// 버튼 활성/비활성 여부
  let isEnabled: Bool

  /// 버튼 탭 액션
  let action: () -> Void

  private var textColor: Color {
    // 배경색은 그대로 두고, 글자색만 모드에 따라 변경
    colorScheme == .dark ? .black : .white
  }

  var body: some View {
    Button(action: {
      if isEnabled {
        action()
      }
    }) {
      Text(title)
        .font(.KoddiExtraBold32)
        .foregroundColor(textColor)
        .frame(maxWidth: .infinity)
        .frame(height: 82)
        .background(
          RoundedRectangle(cornerRadius: 12)
            .fill(isEnabled ? Color.primaryGreen : Color.primaryGreen.opacity(0.4))
        )
    }
    .disabled(!isEnabled)
    .accessibilityLabel(title)
    .accessibilityHint(isEnabled ? "탭하여 \(title)합니다" : "현재 사용할 수 없습니다")
  }
}

// MARK: - Preview

struct AddSubscriptionButton_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      // Light Mode
      AddSubscriptionButton(
        title: "등록 승인 요청",
        colorScheme: .light,
        isEnabled: true,
        action: {}
      )
      .previewDisplayName("Light Mode")
      .previewLayout(.sizeThatFits)
      .padding()
      .background(Color.background(.light))

      // Dark Mode (배경색은 동일, 글자색만 검정)
      AddSubscriptionButton(
        title: "등록 승인 요청",
        colorScheme: .dark,
        isEnabled: true,
        action: {}
      )
      .previewDisplayName("Dark Mode")
      .previewLayout(.sizeThatFits)
      .padding()
      .background(Color.background(.light))
      .preferredColorScheme(.dark)
    }
  }
}
