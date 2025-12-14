//
//  InputFieldSection.swift
//  today-s-sound
//

import SwiftUI

struct InputFieldSection: View {
  let title: String
  let description: String
  let isRequired: Bool
  @Binding var text: String
  let colorScheme: ColorScheme
  let additionalContent: (() -> AnyView)?

  init(
    title: String,
    description: String,
    isRequired: Bool = false,
    text: Binding<String>,
    colorScheme: ColorScheme,
    additionalContent: (() -> AnyView)? = nil
  ) {
    self.title = title
    self.description = description
    self.isRequired = isRequired
    _text = text
    self.colorScheme = colorScheme
    self.additionalContent = additionalContent
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // 타이틀 + 필수(*) 표시
      HStack(spacing: 4) {
        Text(title)
          .font(.KoddiBold20)
          .foregroundColor(Color.text(colorScheme))
          .accessibilityLabel(isRequired ? "\(title) 필수 입력" : title)

        if isRequired {
          Text("*")
            .font(.KoddiBold20)
            .foregroundColor(.red)
            .accessibilityHidden(true)
        }
      }

      // TextField
      TextField("", text: $text)
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .foregroundColor(Color.text(colorScheme))
        .font(.KoddiRegular16)
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(Color.secondaryBackground(colorScheme))
        )
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color.border(colorScheme), lineWidth: 1)
        )
        .accessibilityLabel("\(title) 편집창")
        .accessibilityHint(description)
        .accessibilityValue(text.isEmpty ? "" : text)

      // 추가 컨텐츠 (예: 추천 키워드 배지 등)
      if let additionalContent {
        additionalContent()
      }

      // 설명 텍스트
      Text(description)
        .font(.KoddiRegular16)
        .foregroundColor(Color.secondaryText(colorScheme))
        .accessibilityLabel(description)
    }
  }
}

// MARK: - Preview

struct InputFieldSection_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      VStack(spacing: 24) {
        InputFieldSection(
          title: "웹사이트 URL",
          description: "모니터링할 웹페이지 URL을 입력하세요.",
          isRequired: true,
          text: .constant(""),
          colorScheme: .light
        )

        InputFieldSection(
          title: "웹페이지 별명",
          description: "해당 페이지를 식별할 명칭을 입력하세요. (선택 사항)",
          isRequired: false,
          text: .constant("이미 입력된 값"),
          colorScheme: .light
        )
      }
      .padding()
      .background(Color.background(.light))
      .previewDisplayName("Light Mode")

      VStack(spacing: 24) {
        InputFieldSection(
          title: "웹사이트 URL",
          description: "모니터링할 웹페이지 URL을 입력하세요.",
          isRequired: true,
          text: .constant(""),
          colorScheme: .dark
        )

        InputFieldSection(
          title: "웹페이지 별명",
          description: "해당 페이지를 식별할 명칭을 입력하세요. (선택 사항)",
          isRequired: false,
          text: .constant("이미 입력된 값"),
          colorScheme: .dark
        )
      }
      .padding()
      .background(Color.background(.dark))
      .preferredColorScheme(.dark)
      .previewDisplayName("Dark Mode")
    }
  }
}
