import SwiftUI

struct AddSubscriptionView: View {
  @StateObject private var viewModel: AddSubscriptionViewModel
  @EnvironmentObject var appTheme: AppThemeManager
  @Environment(\.dismiss) var dismiss
  var onSuccess: (() -> Void)?

  init(subscriptionToEdit: SubscriptionItem? = nil, onSuccess: (() -> Void)? = nil) {
    _viewModel = StateObject(wrappedValue: AddSubscriptionViewModel(subscriptionToEdit: subscriptionToEdit))
    self.onSuccess = onSuccess
  }

  var body: some View {
    ZStack {
      Color.background(appTheme.theme)
        .ignoresSafeArea()
        .accessibilityHidden(true)
        .onTapGesture {
          UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }

      VStack(spacing: 0) {
        // 상단 핸들 바
        SheetHandleBar(theme: appTheme.theme) {
          dismiss()
        }
        .accessibilityElement()
        .accessibilityLabel("새 웹페이지 추가 창 닫기")
        .accessibilityHint("탭하거나 두 손가락을 아래로 스와이프하면 창이 닫힙니다")

        // 화면 제목
        ScreenSubTitle(text: viewModel.isEditMode ? "구독 웹페이지 수정" : "새 웹페이지 추가", theme: appTheme.theme)
          .padding(.bottom, 8)
          .padding(.top, 4)

        // 콘텐츠 + 하단 버튼 영역
        VStack(spacing: 0) {
          // 스크롤 되는 영역
          ScrollView {
            VStack(spacing: 24) {
              urlSelectionSection
              nameInputSection
              keywordFilterSection
              urgentToggleSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 8)
          }
          .scrollDismissesKeyboard(.interactively)
          .frame(maxWidth: .infinity, maxHeight: .infinity)

          // 하단 고정 버튼
          submitButtonSection

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
    .sheet(isPresented: $viewModel.showURLSelector) {
      URLSelectorSheet(viewModel: viewModel, theme: appTheme.theme)
        .onAppear {
          if viewModel.availableURLs.isEmpty {
            viewModel.loadURLs()
          }
        }
    }
    .sheet(isPresented: $viewModel.showKeywordSelector) {
      KeywordSelectorSheet(viewModel: viewModel, theme: appTheme.theme)
        .onAppear {
          if viewModel.availableKeywords.isEmpty {
            viewModel.loadKeywords()
          }
        }
    }
    .onAppear {
      // 수정 모드일 때 키워드 목록 자동 로드
      if viewModel.isEditMode, viewModel.availableKeywords.isEmpty {
        viewModel.loadKeywords()
      }
    }
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
        .accessibilityHint("탭하여 키보드를 숨깁니다")
      }
    }
  }

  // MARK: - URL 선택 섹션

  private var urlSelectionSection: some View {
    FormFieldSection(
      title: "웹사이트 URL",
      description: "모니터링할 웹페이지를 선택하세요.",
      isRequired: true,
      theme: appTheme.theme,
      fieldContent: {
        Button(action: {
          if !viewModel.isEditMode {
            viewModel.showURLSelector = true
          }
        }) {
          HStack {
            Text(
              viewModel.isEditMode
                ? (viewModel.subscriptionToEdit?.alias ?? "URL")
                : (viewModel.selectedURL?.title ?? "URL 선택...")
            )
            .font(.KoddiRegular16)
            .foregroundColor(
              viewModel.isEditMode
                ? Color.secondaryText(appTheme.theme)
                : (viewModel.selectedURL == nil
                  ? Color.secondaryText(appTheme.theme)
                  : Color.text(appTheme.theme))
            )
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
        .disabled(viewModel.isEditMode)
        .accessibilityLabel("URL 선택")
        .accessibilityValue(
          viewModel.isEditMode
            ? (viewModel.subscriptionToEdit?.alias ?? "URL")
            : (viewModel.selectedURL?.title ?? "선택 안 됨")
        )
        .accessibilityHint(
          viewModel.isEditMode
            ? "수정 모드에서는 URL을 변경할 수 없습니다"
            : "탭하면 웹사이트 선택 창이 나타납니다"
        )
      }
    )
  }

  // MARK: - 웹페이지 별명 입력 섹션

  private var nameInputSection: some View {
    FormFieldSection(
      title: "웹페이지 별명",
      description: "해당 페이지를 식별할 명칭을 입력하세요.",
      isRequired: false,
      text: $viewModel.nameText,
      theme: appTheme.theme
    )
  }

  // MARK: - 키워드 필터 섹션

  private var keywordFilterSection: some View {
    FormFieldSection(
      title: "키워드 필터",
      description: "관심 키워드가 포함된 글을 알림으로 받아보세요.",
      isRequired: false,
      theme: appTheme.theme,
      fieldContent: {
        Button(action: {
          viewModel.showKeywordSelector = true
        }) {
          HStack {
            Text(viewModel.selectedKeywordNames.isEmpty ? "키워드 추가..." : "키워드 수정...")
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
        .accessibilityLabel(viewModel.selectedKeywordNames.isEmpty ? "키워드 추가" : "키워드 수정")
        .accessibilityHint("탭하면 키워드 선택 창이 나타납니다")
        .accessibilityValue(
          viewModel.selectedKeywordNames.isEmpty
            ? "선택 안 됨"
            : "\(viewModel.selectedKeywordNames.count)개 선택됨"
        )
      },
      additionalContent: {
        AnyView(
          Group {
            if !viewModel.selectedKeywordNames.isEmpty {
              FlowLayout(spacing: 8) {
                ForEach(viewModel.selectedKeywordNames, id: \.self) { keywordName in
                  KeywordBadgeWithDelete(
                    text: keywordName,
                    theme: appTheme.theme
                  ) {
                    if let keyword = viewModel.availableKeywords.first(where: { $0.name == keywordName }) {
                      viewModel.removeKeyword(keyword.id)
                    }
                  }
                }
              }
            }
          }
        )
      }
    )
  }

  // MARK: - 알림 설정 토글 섹션

  private var urgentToggleSection: some View {
    HStack(alignment: .top, spacing: 16) {
      // 타이틀과 설명을 왼쪽에 배치 (보이스오버 순서: 타이틀 → 설명)
      VStack(alignment: .leading, spacing: 12) {
        Text("새로운 글을 알림으로 받기")
          .font(.KoddiBold20)
          .foregroundColor(Color.text(appTheme.theme))

        Text("이 사이트의 모든 새로운 글에 대해 알림을 받습니다.")
          .font(.KoddiRegular16)
          .foregroundColor(Color.secondaryText(appTheme.theme))
          .fixedSize(horizontal: false, vertical: true)
      }
      .accessibilityElement(children: .combine)

      Spacer()

      // 토글을 오른쪽에 배치 (보이스오버에서는 마지막에 읽힘)
      Toggle("", isOn: $viewModel.isAlarmEnabled)
        .labelsHidden()
        .accessibilityLabel("알림")
        .accessibilityValue(viewModel.isAlarmEnabled ? "켜짐" : "꺼짐")
    }
    .padding(.vertical)
  }

  // MARK: - 제출 버튼 섹션

  private var submitButtonSection: some View {
    MainButton(
      title: viewModel.isLoading
        ? (viewModel.isEditMode ? "수정 중..." : "등록 중...")
        : (viewModel.isEditMode ? "수정 완료" : "구독 목록에 추가"),
      theme: appTheme.theme,
      isEnabled: viewModel.isSubmitEnabled && !viewModel.isLoading
    ) {
      viewModel.createSubscription { success in
        if success {
          onSuccess?()
          dismiss()
        }
      }
    }
    .accessibilityLabel(
      viewModel.isLoading
        ? (viewModel.isEditMode ? "수정 중" : "등록 중")
        : (viewModel.isEditMode ? "수정 완료" : "구독 목록에 추가")
    )
    .accessibilityHint(
      viewModel.isLoading
        ? (viewModel.isEditMode ? "수정 중입니다" : "등록 중입니다")
        : viewModel.isEditMode
        ? "구독 정보를 수정합니다"
        : (viewModel.isSubmitEnabled
          ? "이 웹사이트를 구독 목록에 추가합니다"
          : "웹사이트 URL을 선택해야 활성화됩니다")
    )
    .padding(.horizontal, 16)
    .padding(.vertical, 16)
  }
}
