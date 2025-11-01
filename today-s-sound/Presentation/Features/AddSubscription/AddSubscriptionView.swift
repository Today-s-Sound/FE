import SwiftUI

struct AddSubscriptionView: View {
  // 주의: 호출하는 쪽에서 .environmentObject(session)을 넘겨도,
  // ViewModel은 생성 시점에 필요하므로 init(session:) 으로 주입합니다.
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.dismiss) var dismiss

  @StateObject private var viewModel: AddSubscriptionViewModel

  // MARK: - Initializers

  /// 실제 사용: AddSubscriptionView(session: session)
  init(session: SessionStore) {
    _viewModel = StateObject(wrappedValue: AddSubscriptionViewModel(session: session))
  }

  /// 프리뷰/임시용(실서비스에서는 사용하지 마세요)
  init() {
    let dummy = SessionStore()
    _viewModel = StateObject(wrappedValue: AddSubscriptionViewModel(session: dummy))
  }

  var body: some View {
    ZStack {
      Color.background(colorScheme).ignoresSafeArea()

      VStack(spacing: 0) {
        HeaderBar(colorScheme: colorScheme, onClose: { dismiss() })

        ScreenSubTitle(text: "새 웹페이지 추가", colorScheme: colorScheme)

        ScrollView {
          VStack(spacing: 24) {
            // URL
            InputFieldSection(
              title: "웹사이트 URL",
              placeholder: "https://www.example.com",
              description: "모니터링 할 웹페이지 URL을 입력하세요.",
              text: $viewModel.urlText,
              colorScheme: colorScheme
            )

            // 별명 (현재 API에는 전송하지 않지만 UI는 유지)
            InputFieldSection(
              title: "웹페이지 별명",
              placeholder: "동국대학교 공지사항",
              description: "웹 페이지를 식별할 명칭을 입력하세요.",
              text: $viewModel.nameText,
              colorScheme: colorScheme
            )

            // 키워드 필터
            VStack(alignment: .leading, spacing: 12) {
              VStack(alignment: .leading, spacing: 8) {
                Text("키워드 필터")
                  .font(.system(size: 14, weight: .semibold))
                  .foregroundColor(Color.primaryGreen)

                Button(action: { viewModel.showKeywordSelector = true }) {
                  HStack {
                    Text("키워드 추가...")
                      .font(.system(size: 16))
                      .foregroundColor(Color.secondaryText(colorScheme))
                    Spacer()
                  }
                  .padding(.horizontal, 16)
                  .padding(.vertical, 12)
                  .background(
                    RoundedRectangle(cornerRadius: 8)
                      .fill(Color.secondaryBackground(colorScheme))
                  )
                }

                Text("관심 키워드가 포함된 내용을 걸러낼 필요가 있으면 입력하세요.")
                  .font(.system(size: 12))
                  .foregroundColor(Color.secondaryText(colorScheme))
                  .fixedSize(horizontal: false, vertical: true)
              }

              if !viewModel.selectedKeywords.isEmpty {
                FlowLayout(spacing: 8) {
                  ForEach(viewModel.selectedKeywords, id: \.self) { keyword in
                    KeywordBadgeWithDelete(
                      text: keyword,
                      colorScheme: colorScheme
                    ) { viewModel.removeKeyword(keyword) }
                  }
                }
              }
            }

            // 긴급 토글 (현재 API 전송은 보류)
            UrgentToggleRow(isOn: $viewModel.isUrgent, colorScheme: colorScheme)

            // 에러 메시지
            if let err = viewModel.errorMessage {
              Text(err)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 2)
            }

            // 하단 제출 버튼
            Button(action: {
              viewModel.submit()
            }) {
              ZStack {
                Text(viewModel.isLoading ? "요청 중…" : "등록 승인 요청")
                  .font(.system(size: 16, weight: .semibold))
                  .foregroundColor(.white)
                  .frame(maxWidth: .infinity)
                  .padding(.vertical, 16)
                if viewModel.isLoading {
                  ProgressView().tint(.white)
                }
              }
              .background(
                RoundedRectangle(cornerRadius: 12)
                  .fill(viewModel.canSubmit ? Color.primaryGreen90 : Color.primaryGreen90.opacity(0.5))
              )
            }
            .disabled(!viewModel.canSubmit)
          }
          .padding(.horizontal, 16)
          .padding(.top, 8)
          .padding(.bottom, 16)
        }
      }
    }
    // 키워드 선택 시트
    .sheet(isPresented: $viewModel.showKeywordSelector) {
      KeywordSelectorSheet(viewModel: viewModel, colorScheme: colorScheme)
    }
    // 성공 시 자동 닫기
    .onChange(of: viewModel.successSubscriptionId) { newID in
      if newID != nil { dismiss() }
    }
  }
}

// 그대로 유지: 키워드 선택 시트/배지/FlowLayout (네가 준 버전과 동일)
struct KeywordSelectorSheet: View {
  @ObservedObject var viewModel: AddSubscriptionViewModel
  let colorScheme: ColorScheme
  @Environment(\.dismiss) var dismiss

  var body: some View {
    ZStack {
      Color.background(colorScheme).ignoresSafeArea()

      VStack(spacing: 0) {
        HStack {
          Spacer()
          Text("구독 설정")
            .font(.custom("KoddiUD OnGothic Bold", size: 24))
            .foregroundColor(Color.text(colorScheme))
          Spacer()
          Button(action: { dismiss() }) {
            Image(systemName: "xmark")
              .font(.system(size: 20))
              .foregroundColor(Color.text(colorScheme))
          }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 32)

        VStack(alignment: .leading, spacing: 16) {
          HStack {
            Text("키워드 설정")
              .font(.custom("KoddiUD OnGothic Bold", size: 20))
              .foregroundColor(Color.primaryGreen)
            Spacer()
          }
          .padding(.horizontal, 20)

          VStack(spacing: 0) {
            ForEach(Array(viewModel.availableKeywords.enumerated()), id: \.offset) { index, keyword in
              KeywordCheckboxRow(
                keyword: keyword,
                isSelected: viewModel.selectedKeywords.contains(keyword),
                colorScheme: colorScheme
              ) { viewModel.toggleKeyword(keyword) }

              if index < viewModel.availableKeywords.count - 1 {
                Divider()
                  .background(Color.border(colorScheme))
                  .padding(.horizontal, 20)
              }
            }
          }
        }

        Spacer()

        Button(action: { dismiss() }) {
          Text("저장하기")
            .font(.custom("KoddiUD OnGothic Bold", size: 18))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.primaryGreen)
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 34)
      }
    }
  }
}

struct KeywordBadgeWithDelete: View {
  let text: String
  let colorScheme: ColorScheme
  let onDelete: () -> Void

  var body: some View {
    HStack(spacing: 6) {
      Text(text)
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(.white)
      Button(action: onDelete) {
        Image(systemName: "xmark")
          .font(.system(size: 10, weight: .bold))
          .foregroundColor(.white)
      }
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.primaryGreen)
    )
  }
}

struct FlowLayout: Layout {
  var spacing: CGFloat = 8

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    let result = FlowResult(
      in: proposal.replacingUnspecifiedDimensions().width,
      subviews: subviews,
      spacing: spacing
    )
    return result.size
  }

  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
    let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
    for (index, subview) in subviews.enumerated() {
      subview.place(
        at: CGPoint(x: bounds.minX + result.positions[index].x,
                    y: bounds.minY + result.positions[index].y),
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
    AddSubscriptionView() // 미리보기 전용 이니셜라이저
      .preferredColorScheme(.light)
  }
}
