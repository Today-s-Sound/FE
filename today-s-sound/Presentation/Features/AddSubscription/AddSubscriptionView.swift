import SwiftUI

struct AddSubscriptionView: View {
  @StateObject private var viewModel = AddSubscriptionViewModel()
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.dismiss) var dismiss

  var body: some View {
    ZStack {
      Color.background(colorScheme)
        .ignoresSafeArea()
        .onTapGesture {
          // 배경 탭하면 키보드만 닫기
          UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }

      VStack(spacing: 0) {
        // 상단 핸들 바 (X 대신)
        SheetHandleBar(colorScheme: colorScheme)
          .accessibilityElement()
          .accessibilityLabel("새 웹페이지 추가 창 닫기")
          .accessibilityHint("이 영역을 두 번 탭하거나 아래로 스와이프하면 창이 닫힙니다.")
          .onTapGesture {
            // 핸들 바를 두 번 탭해서도 창을 닫을 수 있게
            dismiss()
          }

        // 화면 제목
        ScreenSubTitle(text: "새 웹페이지 추가", colorScheme: colorScheme)
          .padding(.bottom, 8)
          .padding(.top, 4)

        // 콘텐츠 + 하단 버튼 영역
        VStack(spacing: 0) {
          // 스크롤 되는 영역 (입력 필드, 키워드, 토글 등)
          ScrollView {
            VStack(spacing: 24) {
              // 1) 웹사이트 URL (필수)
              InputFieldSection(
                title: "웹사이트 URL",
                description: "모니터링할 웹페이지의 정확한 URL을 입력하세요.",
                isRequired: true,
                text: $viewModel.urlText,
                colorScheme: colorScheme
              )

              // 2) 웹페이지 별명 (선택)
              InputFieldSection(
                title: "웹페이지 별명",
                description: "해당 페이지를 식별할 명칭을 입력하세요.",
                isRequired: false,
                text: $viewModel.nameText,
                colorScheme: colorScheme
              )

              // 3) 키워드 필터
              VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                  Text("키워드 필터")
                    .font(.KoddiBold20)
                    .foregroundColor(Color.text(colorScheme))

                  Button(action: {
                    viewModel.showKeywordSelector = true
                  }) {
                    HStack {
                      Text(viewModel.selectedKeywords.isEmpty ? "키워드 추가..." : "키워드 수정...")
                        .font(.KoddiRegular16)
                        .foregroundColor(Color.secondaryText(colorScheme))
                      Spacer()
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .background(
                      RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondaryBackground(colorScheme))
                    )
                    .overlay(
                      RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.border(colorScheme), lineWidth: 1)
                    )
                  }
                  .accessibilityLabel(viewModel.selectedKeywords.isEmpty ? "키워드 추가 버튼" : "키워드 수정 버튼")
                  .accessibilityHint("탭하여 키워드를 선택합니다")

                  Text("관심 키워드가 포함된 글을 알림으로 받아보세요.")
                    .font(.KoddiRegular16)
                    .foregroundColor(Color.secondaryText(colorScheme))
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel("관심 키워드가 포함된 글을 알림으로 받아보세요")
                }

                // 선택된 키워드 배지들
                if !viewModel.selectedKeywords.isEmpty {
                  FlowLayout(spacing: 8) {
                    ForEach(viewModel.selectedKeywords, id: \.self) { keyword in
                      KeywordBadgeWithDelete(
                        text: keyword,
                        colorScheme: colorScheme
                      ) {
                        viewModel.removeKeyword(keyword)
                      }
                    }
                  }
                }
              }

              // 4) 긴급 알림 토글
              HStack {
                Text("긴급 알림으로 설정")
                  .font(.KoddiBold20)
                  .foregroundColor(Color.text(colorScheme))
                  .accessibilityLabel("긴급 알림으로 설정")
                Spacer()
                Toggle("", isOn: $viewModel.isUrgent)
                  .labelsHidden()
                  .accessibilityLabel("긴급 알림 토글")
                  .accessibilityValue(viewModel.isUrgent ? "켜짐" : "꺼짐")
                  .accessibilityHint("탭하여 긴급 알림 설정을 변경합니다")
              }
              .padding(.vertical)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 8)
          }
          .scrollDismissesKeyboard(.interactively)
          .frame(maxWidth: .infinity, maxHeight: .infinity)

          // 하단 고정 "등록 승인 요청" 버튼
          AddSubscriptionButton(
            title: "등록 승인 요청",
            colorScheme: colorScheme,
            isEnabled: viewModel.isSubmitEnabled
          ) {
            let payload = viewModel.makeRequestPayload()
            // TODO: 나중에 여기서 API 서비스에 payload를 넘겨서 서버로 전송
            print("📤 New Subscription Request:", payload)
            dismiss()
          }
          // 접근성: 활성/비활성 상태에 따라 안내 문구 변경
          .accessibilityLabel("등록 승인 요청, 버튼")
          .accessibilityHint(
            viewModel.isSubmitEnabled
              ? "이 웹사이트 등록 승인을 요청합니다."
              : "웹사이트 URL을 입력해야 활성화됩니다."
          )
          .padding(.horizontal, 16)
          .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
    .ignoresSafeArea(.keyboard, edges: .bottom)
    // 키워드 설정 시트
    .sheet(isPresented: $viewModel.showKeywordSelector) {
      KeywordSelectorSheet(viewModel: viewModel, colorScheme: colorScheme)
    }
    // 키보드 상단에 항상 "키보드 닫기" 버튼 제공
    .toolbar {
      ToolbarItemGroup(placement: .keyboard) {
        Spacer()
        Button("키보드 닫기") {
          UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
          )
        }
        .accessibilityLabel("키보드 닫기")
        .accessibilityHint("탭하여 키보드를 숨깁니다.")
      }
    }
  }
}

// MARK: - 키워드 선택 시트

struct KeywordSelectorSheet: View {
  @ObservedObject var viewModel: AddSubscriptionViewModel
  let colorScheme: ColorScheme
  @Environment(\.dismiss) var dismiss

  var body: some View {
    ZStack {
      Color.background(colorScheme)
        .ignoresSafeArea()
        .onTapGesture {
          UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }

      VStack(spacing: 0) {
        SheetHandleBar(colorScheme: colorScheme)
          .padding(.top, 20)
          .accessibilityElement()
          .accessibilityLabel("키워드 설정 창 닫기")
          .accessibilityHint("이 영역을 두 번 탭하거나 아래로 스와이프하면 창이 닫힙니다.")
          .onTapGesture {
            dismiss()
          }

        // 키워드 설정 화면 제목
        ScreenSubTitle(text: "키워드 설정", colorScheme: colorScheme)

        VStack(spacing: 0) {
          // 스크롤 가능한 키워드 목록
          ScrollView {
            VStack(alignment: .leading, spacing: 16) {
              if viewModel.availableKeywords.isEmpty {
                VStack(spacing: 16) {
                  Text("등록된 키워드가 없습니다.")
                    .font(.KoddiBold20)
                    .foregroundColor(Color.secondaryText(colorScheme))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
              } else {
                VStack(spacing: 0) {
                  ForEach(Array(viewModel.availableKeywords.enumerated()), id: \.offset) { index, keyword in
                    KeywordCheckboxRow(
                      keyword: keyword,
                      isSelected: viewModel.selectedKeywords.contains(keyword),
                      colorScheme: colorScheme
                    ) {
                      viewModel.toggleKeyword(keyword)
                    }

                    if index < viewModel.availableKeywords.count - 1 {
                      Divider()
                        .background(Color.border(colorScheme))
                        .padding(.horizontal, 20)
                    }
                  }
                }
              }
            }
            .padding(.top, 8)
            .padding(.bottom, 8)
          }
          .scrollDismissesKeyboard(.interactively)
          .frame(maxWidth: .infinity, maxHeight: .infinity)

          // 하단 고정 "저장하기" 버튼
          AddSubscriptionButton(
            title: "저장하기",
            colorScheme: colorScheme,
            isEnabled: true
          ) {
            dismiss()
          }
          .padding(.horizontal, 20)
          .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
  }
}

// MARK: - 키워드 배지 + FlowLayout (파일 내부용)

/// 삭제 버튼이 있는 키워드 배지
struct KeywordBadgeWithDelete: View {
  let text: String
  let colorScheme: ColorScheme
  let onDelete: () -> Void

  var body: some View {
    HStack(spacing: 6) {
      Text(text)
        .font(.KoddiBold14)
        .foregroundColor(.primaryGreen)

      Button(action: onDelete) {
        Image(systemName: "xmark")
          .font(.KoddiBold14)
          .foregroundColor(.primaryGreen)
      }
      .accessibilityLabel("\(text) 키워드 삭제")
      .accessibilityHint("탭하여 이 키워드를 제거합니다")
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(
      RoundedRectangle(cornerRadius: 20)
        .fill(Color.badgeGreenBackground)
    )
    .overlay(
      RoundedRectangle(cornerRadius: 20)
        .stroke(Color.primaryGreen, lineWidth: 1)
    )
    .accessibilityElement(children: .combine)
    .accessibilityLabel("선택된 키워드: \(text)")
  }
}

/// 여러 배지를 자동으로 줄바꿈해 배치해주는 레이아웃
struct FlowLayout: Layout {
  var spacing: CGFloat = 8

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    let maxWidth = proposal.replacingUnspecifiedDimensions().width
    let result = FlowResult(in: maxWidth, subviews: subviews, spacing: spacing)
    return result.size
  }

  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
    let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
    for (index, subview) in subviews.enumerated() {
      subview.place(
        at: CGPoint(
          x: bounds.minX + result.positions[index].x,
          y: bounds.minY + result.positions[index].y
        ),
        proposal: .unspecified
      )
    }
  }

  struct FlowResult {
    var size: CGSize = .zero
    var positions: [CGPoint] = []

    init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
      var currentX: CGFloat = 0
      var currentY: CGFloat = 0
      var lineHeight: CGFloat = 0

      for subview in subviews {
        let size = subview.sizeThatFits(.unspecified)

        if currentX + size.width > maxWidth, currentX > 0 {
          currentX = 0
          currentY += lineHeight + spacing
          lineHeight = 0
        }

        positions.append(CGPoint(x: currentX, y: currentY))
        lineHeight = max(lineHeight, size.height)
        currentX += size.width + spacing
      }

      size = CGSize(width: maxWidth, height: currentY + lineHeight)
    }
  }
}

struct AddSubscriptionView_Previews: PreviewProvider {
  static var previews: some View {
    AddSubscriptionView()
  }
}
