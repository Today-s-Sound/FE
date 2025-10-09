//
//  InputFieldSection.swift
//  today-s-sound
//
//  Created by Assistant on 12/19/24.
//

import SwiftUI

struct InputFieldSection: View {
  let title: String
  let placeholder: String
  let description: String
  @Binding var text: String
  let colorScheme: ColorScheme
  let additionalContent: (() -> AnyView)?

  init(
    title: String,
    placeholder: String,
    description: String,
    text: Binding<String>,
    colorScheme: ColorScheme,
    additionalContent: (() -> AnyView)? = nil
  ) {
    self.title = title
    self.placeholder = placeholder
    self.description = description
    _text = text
    self.colorScheme = colorScheme
    self.additionalContent = additionalContent
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .font(.system(size: 16, weight: .semibold))
        .foregroundColor(Color.text(colorScheme))
//                .background(
//                    RoundedRectangle(cornerRadius: 12)
//                        .fill(Color.secondaryBackground(colorScheme))
//                )

      TextField(placeholder, text: $text)
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 12)
            .fill(Color.secondaryBackground(colorScheme))
            .stroke(Color.border(colorScheme), lineWidth: 1)
        )
        .foregroundColor(Color.text(colorScheme))

      if let additionalContent {
        additionalContent()
      }

      Text(description)
        .font(.system(size: 13))
        .foregroundColor(Color.secondaryText(colorScheme))
    }
  }
}

struct InputFieldSection_Previews: PreviewProvider {
  static var previews: some View {
    VStack(spacing: 24) {
      InputFieldSection(
        title: "웹사이트 URL",
        placeholder: "https://www.example.com",
        description: "모니터링 할 웹페이지 URL을 입력하세요.",
        text: .constant(""),
        colorScheme: .light
      )

      InputFieldSection(
        title: "키워드 필터",
        placeholder: "장학금, 교직, 학생회",
        description: "관심 키워드가 포함된 내용을 걸러낼 필요가 있으면 입력하세요.",
        text: .constant(""),
        colorScheme: .dark,
        additionalContent: {
          AnyView(
            HStack(spacing: 8) {
              KeywordBadge(text: "장학금", colorScheme: .dark)
              KeywordBadge(text: "교직부공지사항", colorScheme: .dark)
            }
          )
        }
      )
    }
    .padding()
  }
}
