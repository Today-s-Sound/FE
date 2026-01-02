//
//  URLSelectorSheet.swift
//  today-s-sound
//
//  URL 선택 시트 컴포넌트
//

import SwiftUI

struct URLSelectorSheet: View {
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
        .accessibilityLabel("URL 설정 창 닫기")
        .accessibilityHint("탭하거나 두 손가락을 아래로 스와이프하면 창이 닫힙니다")

        // URL 설정 화면 제목
        ScreenSubTitle(text: "URL 선택", theme: theme)

        VStack(spacing: 0) {
          // 스크롤 가능한 URL 목록
          ScrollView {
            VStack(alignment: .leading, spacing: 16) {
              if viewModel.isLoadingURLs {
                VStack(spacing: 16) {
                  ProgressView("불러오는 중...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .accessibilityLabel("URL 목록을 불러오는 중입니다")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
              } else if let errorMessage = viewModel.urlErrorMessage {
                VStack(spacing: 16) {
                  Text(errorMessage)
                    .font(.KoddiBold20)
                    .foregroundColor(Color.secondaryText(theme))
                    .accessibilityLabel("오류: \(errorMessage)")

                  Button("다시 시도") {
                    viewModel.loadURLs()
                  }
                  .padding(.horizontal, 24)
                  .padding(.vertical, 12)
                  .font(.KoddiBold20)
                  .foregroundColor(.white)
                  .background(Color.primaryGreen)
                  .cornerRadius(8)
                  .accessibilityLabel("다시 시도")
                  .accessibilityHint("탭하여 URL 목록을 다시 불러옵니다")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
              } else if viewModel.availableURLs.isEmpty {
                VStack(spacing: 16) {
                  Text("등록된 URL이 없습니다.")
                    .font(.KoddiBold20)
                    .foregroundColor(Color.secondaryText(theme))
                    .accessibilityLabel("등록된 URL이 없습니다")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
              } else {
                VStack(spacing: 0) {
                  ForEach(Array(viewModel.availableURLs.enumerated()), id: \.element.id) { index, url in
                    URLRow(
                      url: url,
                      isSelected: viewModel.selectedURL?.id == url.id,
                      theme: theme
                    ) {
                      viewModel.selectURL(url)
                      dismiss()
                    }

                    if index < viewModel.availableURLs.count - 1 {
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
  }
}

// MARK: - URL 행 컴포넌트

struct URLRow: View {
  let url: URLItem
  let isSelected: Bool
  let theme: AppTheme
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 16) {
        VStack(alignment: .leading, spacing: 4) {
          Text(url.title)
            .font(.KoddiBold20)
            .foregroundColor(Color.text(theme))

          Text(url.link)
            .font(.KoddiRegular16)
            .foregroundColor(Color.secondaryText(theme))
            .lineLimit(1)
        }

        Spacer()

        if isSelected {
          Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 24))
            .foregroundColor(Color.primaryGreen)
        } else {
          Image(systemName: "circle")
            .font(.system(size: 24))
            .foregroundColor(Color.border(theme))
        }
      }
      .padding(.vertical, 16)
      .padding(.horizontal, 20)
    }
    .buttonStyle(PlainButtonStyle())
    .accessibilityValue(isSelected ? "선택됨" : "선택 안 됨")
    .accessibilityHint("탭하여 이 URL을 선택합니다")
  }
}

