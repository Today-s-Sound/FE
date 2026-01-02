//
//  FormFieldSection.swift
//  today-s-sound
//
//  소제목-설명-필드 구조를 가진 범용 폼 섹션 컴포넌트
//  필드는 TextField일 수도 있고 Button일 수도 있음
//

import SwiftUI

struct FormFieldSection<FieldContent: View>: View {
  let title: String
  let description: String
  let isRequired: Bool
  let theme: AppTheme
  let fieldContent: () -> FieldContent
  let additionalContent: (() -> AnyView)?

  init(
    title: String,
    description: String,
    isRequired: Bool = false,
    theme: AppTheme,
    @ViewBuilder fieldContent: @escaping () -> FieldContent,
    additionalContent: (() -> AnyView)? = nil
  ) {
    self.title = title
    self.description = description
    self.isRequired = isRequired
    self.theme = theme
    self.fieldContent = fieldContent
    self.additionalContent = additionalContent
  }

    var body: some View {
    VStack(alignment: .leading, spacing: 12) {
        VStack(alignment: .leading, spacing: 12) {
        // 소제목 + 필수(*) 표시
        HStack(spacing: 4) {
            Text(title)
            .font(.KoddiBold20)
            .foregroundColor(Color.text(theme))

            if isRequired {
            Text("*")
                .font(.KoddiBold20)
                .foregroundColor(.red)
                .accessibilityHidden(true)
            }
        }
        // 설명
        Text(description)
            .font(.KoddiRegular16)
            .foregroundColor(Color.secondaryText(theme))
            .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(isRequired ? "\(title), 필수 항목, \(description)" : "\(title), \(description)")

        // 필드 (TextField 또는 Button)
        fieldContent()

        // 추가 컨텐츠
        if let additionalContent {
        additionalContent()
        }
    }
    }

}

// MARK: - TextField 전용 편의 이니셜라이저

extension FormFieldSection {
  /// TextField를 위한 편의 이니셜라이저
  /// InputFieldSection을 대체하는 용도
  init(
    title: String,
    description: String,
    isRequired: Bool = false,
    text: Binding<String>,
    theme: AppTheme,
    additionalContent: (() -> AnyView)? = nil
  ) where FieldContent == AnyView {
    self.title = title
    self.description = description
    self.isRequired = isRequired
    self.theme = theme
    self.additionalContent = additionalContent
    
    // TextField 생성
    self.fieldContent = {
      AnyView(
        TextField("", text: text)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled()
          .keyboardType(isRequired ? .URL : .default)
          .padding(.horizontal, 18)
          .padding(.vertical, 16)
          .foregroundColor(Color.text(theme))
          .font(.KoddiRegular16)
          .contentShape(Rectangle())
          .background(
            RoundedRectangle(cornerRadius: 8)
              .fill(Color.secondaryBackground(theme))
          )
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .stroke(Color.border(theme), lineWidth: 1)
          )
          .accessibilityLabel(title)
      )
    }
  }
}

