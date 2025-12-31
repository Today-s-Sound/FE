import SwiftUI

struct HomeView: View {
  @StateObject private var viewModel = MainViewModel()
  @ObservedObject private var speechService = SpeechService.shared
  @EnvironmentObject var appTheme: AppThemeManager
    
    private var currentCategoryA11yLabel: String {
      if viewModel.isLoading {
        return "현재 카테고리, 새로운 글을 불러오는 중입니다"
      } else if viewModel.currentCategoryName.isEmpty {
        return "현재 카테고리, 등록된 페이지가 없습니다. 구독을 추가해주세요."
      } else {
        return "현재 카테고리, \(viewModel.currentCategoryName)"
      }
    }
    
  var body: some View {
    ZStack {
      Color.background(appTheme.theme)
        .ignoresSafeArea()

      VStack(spacing: 0) {
        // 오늘의 소리 타이틀
        Text("오늘의 소리")
          .font(.KoddiBold56)
          .foregroundStyle(Color.text(appTheme.theme))
          .padding(.top, 120)
          .padding(.bottom, 60)
          .accessibilityElement()
          .accessibilityLabel("오늘의 소리")
          .accessibilityAddTraits(.isHeader)

        Button(
          action: {
            if speechService.isSpeaking {
              speechService.stop()
            } else {
              // 홈 피드가 있으면 첫 번째 피드 아이템 재생
              if !viewModel.homeFeedItems.isEmpty {
                viewModel.playFirstFeedItem()
              }
            }
          },
          label: {
            Image(speechService.isSpeaking ? "pause" : "play")
              .resizable()
              .scaledToFit()
              .frame(width: 180, height: 180)
              .padding(20)
          }
        )
        .accessibilityLabel(speechService.isSpeaking ? "재생 중단" : "재생 시작")
        .padding(.bottom, 60)

        Spacer()

          VStack(spacing: 16) {
              Text("현재 카테고리")
                  .font(.KoddiBold28)
                  .foregroundColor(Color.text(appTheme.theme))
                  .accessibilityHidden(true)
              
              Group {
                  if viewModel.isLoading {
                      Text("불러오는 중...")
                  } else if viewModel.currentCategoryName.isEmpty {
                      Text("등록된 페이지 없음")
                  } else {
                      Text(viewModel.currentCategoryName)
                  }
              }
              .font(.KoddiExtraBold32)
              .foregroundColor(.white)
              .padding(.horizontal, 32)
              .padding(.vertical, 18)
              .frame(width: 360, height: 84)
              .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(viewModel.isLoading || viewModel.currentCategoryName.isEmpty
                          ? Color.primaryGreen.opacity(0.6)
                          : Color.primaryGreen)
              )
              .accessibilityHidden(true)
          }
          .padding(.bottom, 16)
          .accessibilityElement(children: .ignore)
          .accessibilityLabel(currentCategoryA11yLabel)
      }
    }
    .onAppear {
      viewModel.loadHomeFeed()
    }
  }
}

#Preview {
  HomeView()
    .environmentObject(AppThemeManager())
}
