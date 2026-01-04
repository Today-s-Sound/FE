//
//  KeywordSelectorSheet.swift
//  today-s-sound
//
//  키워드 선택 시트 컴포넌트
//

import SwiftUI

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
        SheetHandleBar(theme: theme) {
          dismiss()
        }
        .padding(.top, 20)
        .accessibilityElement()
        .accessibilityLabel("키워드 설정 창 닫기")
        .accessibilityHint("탭하거나 아래로 스와이프하면 창이 닫힙니다")

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
                  .accessibilityLabel("다시 시도")
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
                  ForEach(Array(viewModel.availableKeywords.enumerated()), id: \.element.id) { index, keyword in
                    KeywordCheckboxRow(
                      keyword: keyword.name,
                      isSelected: viewModel.selectedKeywordIds.contains(keyword.id),
                      theme: theme
                    ) {
                      viewModel.toggleKeyword(keyword.id)
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
          MainButton(
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

