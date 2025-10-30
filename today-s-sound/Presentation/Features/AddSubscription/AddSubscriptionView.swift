import SwiftUI

struct AddSubscriptionView: View {
  @StateObject private var viewModel = AddSubscriptionViewModel()
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.dismiss) var dismiss

  var body: some View {
    ZStack {
      Color.background(colorScheme)
        .ignoresSafeArea()

      VStack(spacing: 0) {
        HeaderBar(colorScheme: colorScheme, onClose: { dismiss() })

        ScreenSubTitle(text: "새 웹페이지 추가", colorScheme: colorScheme)

        ScrollView {
          VStack(spacing: 24) {
            InputFieldSection(
              title: "웹사이트 URL",
              placeholder: "https://www.example.com",
              description: "모니터링 할 웹페이지 URL을 입력하세요.",
              text: $viewModel.urlText,
              colorScheme: colorScheme
            )

            InputFieldSection(
              title: "웹페이지 별명",
              placeholder: "동국대학교 공지사항",
              description: "웹 페이지를 식별할 명칭을 입력하세요.",
              text: $viewModel.nameText,
              colorScheme: colorScheme
            )

            VStack(alignment: .leading, spacing: 12) {
              // 키워드 필터 섹션
              VStack(alignment: .leading, spacing: 8) {
                Text("키워드 필터")
                  .font(.system(size: 14, weight: .semibold))
                  .foregroundColor(Color.primaryGreen)

                // 키워드 추가 버튼
                Button(action: {
                  viewModel.showKeywordSelector = true
                }) {
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

            UrgentToggleRow(isOn: $viewModel.isUrgent, colorScheme: colorScheme)

            // 하단 버튼
            Button(action: {
              dismiss()
            }, label: {
              Text("등록 승인 요청")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                  RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primaryGreen90)
                )
            })
          }
          .padding(.horizontal, 16)
          .padding(.top, 8)
          .padding(.bottom, 16)
        }
      }
    }
    .sheet(isPresented: $viewModel.showKeywordSelector) {
      KeywordSelectorSheet(viewModel: viewModel, colorScheme: colorScheme)
    }
  }
}

// 키워드 선택 시트
struct KeywordSelectorSheet: View {
  @ObservedObject var viewModel: AddSubscriptionViewModel
  let colorScheme: ColorScheme
  @Environment(\.dismiss) var dismiss

  var body: some View {
    ZStack {
      Color.background(colorScheme)
        .ignoresSafeArea()

      VStack(spacing: 0) {
        // 헤더
        HStack {
          Spacer()
          Text("구독 설정")
            .font(.custom("KoddiUD OnGothic Bold", size: 24))
            .foregroundColor(Color.text(colorScheme))
          Spacer()
          Button(action: {
            dismiss()
          }) {
            Image(systemName: "xmark")
              .font(.system(size: 20))
              .foregroundColor(Color.text(colorScheme))
          }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 32)

        // 키워드 설정 섹션
        VStack(alignment: .leading, spacing: 16) {
          HStack {
            Text("키워드 설정")
              .font(.custom("KoddiUD OnGothic Bold", size: 20))
              .foregroundColor(Color.primaryGreen)

            Spacer()
          }
          .padding(.horizontal, 20)

          // 키워드 체크박스 리스트
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

        Spacer()

        // 저장하기 버튼
        Button(action: {
          dismiss()
        }) {
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

// 삭제 가능한 키워드 배지
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

// FlowLayout for keywords
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
    let result = FlowResult(
      in: bounds.width,
      subviews: subviews,
      spacing: spacing
    )
    for (index, subview) in subviews.enumerated() {
      subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
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
