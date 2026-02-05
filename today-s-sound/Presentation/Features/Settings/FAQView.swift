//
//  FAQView.swift
//  today-s-sound
//

import SwiftUI

struct FAQItem: Identifiable {
  let id = UUID()
  let question: String
  let answer: String
}

struct FAQView: View {
  let theme: AppTheme

  @State private var expandedItems: Set<UUID> = []

  private let faqItems: [FAQItem] = [
    FAQItem(
      question: "홈 탭과 피드 탭, 알림 탭에 아무것도 없어요.",
      answer: "오늘의 소리는 앱 설치 후 관리 탭에서 원하는 구독 페이지를 추가하고, 구독 페이지에서 새로운 글이 발행되어야 탐색할 내용이 생성됩니다. 홈 탭과 피드 탭은 새로운 글이 올라와야 확인하실 수 있으니 해당 페이지에 새 글이 올라올 때까지 기다려주세요."
    ),
    FAQItem(
      question: "홈 탭에서 재생 버튼을 눌러도 아무 소리가 나지 않아요.",
      answer: "구독한 페이지에서 새로운 글이 올라와야 재생할 내용이 생깁니다. 먼저 관리 탭에서 페이지를 구독하고, 해당 페이지에 새 글이 올라올 때까지 기다려주세요."
    ),
    FAQItem(
      question: "구독한 페이지에서 새 글이 올라왔는데 알림이 오지 않아요.",
      answer: "알림은 설정한 키워드가 포함된 글이 올라오거나, 새 글 알림 설정이 켜진 페이지에서만 발송됩니다. 관리 탭에서 구독 페이지의 알림과 키워드 설정을 확인해주세요."
    ),
    FAQItem(
      question: "원하는 웹사이트랑 키워드가 없어요.",
      answer: "todaysound.official@gmail.com 으로 원하는 웹사이트 또는 키워드를 요청해주시면 빠른 시일 내에 반영하도록 하겠습니다. 관리 탭의 개발자에게 문의 메뉴에서 이메일 주소를 손쉽게 복사하실 수 있습니다."
    )
  ]

  var body: some View {
    ScrollView {
      VStack(spacing: 0) {
        ForEach(faqItems) { item in
          FAQItemView(
            item: item,
            theme: theme,
            isExpanded: expandedItems.contains(item.id),
            onToggle: {
              withAnimation(.easeInOut(duration: 0.2)) {
                if expandedItems.contains(item.id) {
                  expandedItems.remove(item.id)
                } else {
                  expandedItems.insert(item.id)
                }
              }
            }
          )

          Divider()
            .background(Color.border(theme))
            .padding(.horizontal, 16)
            .accessibilityHidden(true)
        }
      }
      .padding(.vertical, 16)
    }
    .background(Color.background(theme))
  }
}

struct FAQItemView: View {
  let item: FAQItem
  let theme: AppTheme
  let isExpanded: Bool
  let onToggle: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      // 질문 버튼
      Button(action: onToggle) {
        HStack(alignment: .top, spacing: 8) {
          Text("Q.")
            .font(.KoddiBold28)
            .foregroundColor(.primaryGreen)

          Text(item.question)
            .font(.KoddiBold20)
            .foregroundColor(Color.text(theme))
            .multilineTextAlignment(.leading)

          Spacer()

          Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(Color.text(theme))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
      }
      .buttonStyle(PlainButtonStyle())
      .accessibilityLabel("질문: \(item.question)")
      .accessibilityHint(isExpanded ? "탭하면 답변을 접습니다" : "탭하면 답변을 확인할 수 있습니다")
      .accessibilityValue(isExpanded ? "펼쳐짐" : "접힘")

      // 답변 (펼쳐졌을 때만 표시)
      if isExpanded {
        HStack(alignment: .top, spacing: 8) {
          Text("A.")
            .font(.KoddiBold28)
            .foregroundColor(.primaryGreen)

          Text(item.answer)
            .font(.KoddiRegular20)
            .foregroundColor(Color.text(theme))
            .multilineTextAlignment(.leading)

          Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .accessibilityLabel("답변: \(item.answer)")
      }
    }
  }
}

#Preview("자주 묻는 질문 - 라이트") {
  FAQView(theme: .normal)
}

#Preview("자주 묻는 질문 - 고대비") {
  FAQView(theme: .highContrast)
}
