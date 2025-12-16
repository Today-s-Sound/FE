import SwiftUI

struct AddSubscriptionView: View {
  @StateObject private var viewModel = AddSubscriptionViewModel()
  @EnvironmentObject var appTheme: AppThemeManager
  @Environment(\.dismiss) var dismiss

  var body: some View {
    ZStack {
      Color.background(appTheme.theme)
        .ignoresSafeArea()
        .onTapGesture {
          // 배경 탭하면 키보드만 닫기
          UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }

      VStack(spacing: 0) {
        // 상단 핸들 바 (X 대신)
        SheetHandleBar(theme: appTheme.theme)
          .accessibilityElement()
          .accessibilityLabel("새 웹페이지 추가 창 닫기")
          .accessibilityHint("이 영역을 두 번 탭하거나 아래로 스와이프하면 창이 닫힙니다.")
          .onTapGesture {
            // 핸들 바를 두 번 탭해서도 창을 닫을 수 있게
            dismiss()
          }

        // 화면 제목
        ScreenSubTitle(text: "새 웹페이지 추가", theme: appTheme.theme)
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
                theme: appTheme.theme
              )

              // 2) 웹페이지 별명 (선택)
              InputFieldSection(
                title: "웹페이지 별명",
                description: "해당 페이지를 식별할 명칭을 입력하세요.",
                isRequired: false,
                text: $viewModel.nameText,
                theme: appTheme.theme
              )

              // 3) 키워드 필터
              VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                  Text("키워드 필터")
                    .font(.KoddiBold20)
                    .foregroundColor(Color.text(appTheme.theme))

                  Button(action: {
                    viewModel.showKeywordSelector = true
                  }) {
                    HStack {
                      Text(viewModel.selectedKeywords.isEmpty ? "키워드 추가..." : "키워드 수정...")
                        .font(.KoddiRegular16)
                        .foregroundColor(Color.secondaryText(appTheme.theme))
                      Spacer()
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .background(
                      RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondaryBackground(appTheme.theme))
                    )
                    .overlay(
                      RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.border(appTheme.theme), lineWidth: 1)
                    )
                  }
                  .accessibilityLabel(viewModel.selectedKeywords.isEmpty ? "키워드 추가 버튼" : "키워드 수정 버튼")
                  .accessibilityHint("탭하여 키워드를 선택합니다")

                  Text("관심 키워드가 포함된 글을 알림으로 받아보세요.")
                    .font(.KoddiRegular16)
                    .foregroundColor(Color.secondaryText(appTheme.theme))
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel("관심 키워드가 포함된 글을 알림으로 받아보세요")
                }

                // 선택된 키워드 배지들
                if !viewModel.selectedKeywords.isEmpty {
                  FlowLayout(spacing: 8) {
                    ForEach(viewModel.selectedKeywords, id: \.self) { keyword in
                      KeywordBadgeWithDelete(
                        text: keyword,
                        theme: appTheme.theme
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
                  .foregroundColor(Color.text(appTheme.theme))
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
            title: viewModel.isLoading ? "등록 중..." : "등록 승인 요청",
            theme: appTheme.theme,
            isEnabled: viewModel.isSubmitEnabled && !viewModel.isLoading
          ) {
            viewModel.createSubscription { success in
              if success {
                dismiss()
              }
            }
          }
          // 접근성: 활성/비활성 상태에 따라 안내 문구 변경
          .accessibilityLabel(viewModel.isLoading ? "등록 중, 버튼" : "등록 승인 요청, 버튼")
          .accessibilityHint(
            viewModel.isLoading
              ? "구독을 등록하는 중입니다"
              : viewModel.isSubmitEnabled
              ? "이 웹사이트 등록 승인을 요청합니다."
              : "웹사이트 URL을 입력해야 활성화됩니다."
          )
          .padding(.horizontal, 16)
          .padding(.vertical, 16)

          // 에러 메시지 표시
          if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
              .font(.KoddiBold16)
              .foregroundColor(.red)
              .padding(.horizontal, 16)
              .padding(.bottom, 8)
              .accessibilityLabel("오류: \(errorMessage)")
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
    .ignoresSafeArea(.keyboard, edges: .bottom)
    // 키워드 설정 시트
    .sheet(isPresented: $viewModel.showKeywordSelector) {
      KeywordSelectorSheet(viewModel: viewModel, theme: appTheme.theme)
        .onAppear {
          // 키워드 설정 시트가 열릴 때 키워드 목록 로드
          if viewModel.availableKeywords.isEmpty {
            viewModel.loadKeywords()
          }
        }
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
  let theme: AppTheme
  @Environment(\.dismiss) var dismiss

  var body: some View {
    ZStack {
      Color.background(theme)
        .ignoresSafeArea()
        .onTapGesture {
          UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }

      VStack(spacing: 0) {
        SheetHandleBar(theme: theme)
          .padding(.top, 20)
          .accessibilityElement()
          .accessibilityLabel("키워드 설정 창 닫기")
          .accessibilityHint("이 영역을 두 번 탭하거나 아래로 스와이프하면 창이 닫힙니다.")
          .onTapGesture {
            dismiss()
          }

        // 키워드 설정 화면 제목
        ScreenSubTitle(text: "키워드 설정", theme: theme)

        VStack(spacing: 0) {
          // 스크롤 가능한 키워드 목록
          ScrollView {
            VStack(alignment: .leading, spacing: 16) {
              if viewModel.isLoadingKeywords {
                VStack(spacing: 16) {
                  ProgressView("불러오는 중...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .accessibilityLabel("키워드 목록을 불러오는 중입니다")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
              } else if let errorMessage = viewModel.keywordErrorMessage {
                VStack(spacing: 16) {
                  Text(errorMessage)
                    .font(.KoddiBold20)
                    .foregroundColor(Color.secondaryText(theme))
                    .accessibilityLabel("오류: \(errorMessage)")

                  Button("다시 시도") {
                    viewModel.loadKeywords()
                  }
                  .padding(.horizontal, 24)
                  .padding(.vertical, 12)
                  .font(.KoddiBold20)
                  .foregroundColor(.white)
                  .background(Color.primaryGreen)
                  .cornerRadius(8)
                  .accessibilityLabel("다시 시도 버튼")
                  .accessibilityHint("탭하여 키워드 목록을 다시 불러옵니다")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
              } else if viewModel.availableKeywords.isEmpty {
                VStack(spacing: 16) {
                  Text("등록된 키워드가 없습니다.")
                    .font(.KoddiBold20)
                    .foregroundColor(Color.secondaryText(theme))
                    .accessibilityLabel("등록된 키워드가 없습니다")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
              } else {
                VStack(spacing: 0) {
                  ForEach(Array(viewModel.availableKeywords.enumerated()), id: \.offset) { index, keyword in
                    KeywordCheckboxRow(
                      keyword: keyword,
                      isSelected: viewModel.selectedKeywords.contains(keyword),
                      theme: theme
                    ) {
                      viewModel.toggleKeyword(keyword)
                    }

                    if index < viewModel.availableKeywords.count - 1 {
                      Divider()
                        .background(Color.border(theme))
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
            theme: theme,
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
  let theme: AppTheme
  let onDelete: () -> Void
  // theme 파라미터는 현재 사용되지 않지만, 향후 테마 적용을 위해 유지

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
      .environmentObject(AppThemeManager())
  }
}
