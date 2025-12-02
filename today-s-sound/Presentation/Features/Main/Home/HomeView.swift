import SwiftUI

struct HomeView: View {
  @StateObject private var viewModel = MainViewModel()
  @ObservedObject private var speechService = SpeechService.shared
  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    ZStack {
      // 다크모드에 따라 배경색 변경
      Color.background(colorScheme)
        .ignoresSafeArea()

      VStack(spacing: 0) {
        Spacer()

        // 오늘의 소리 타이틀
        Text("오늘의 소리")
          .font(.KoddiBold56)
          .foregroundStyle(Color.text(colorScheme))
          .padding(.bottom, 30)
          .accessibilityElement() // 이 텍스트를 독립 요소로
          .accessibilityLabel("오늘의 소리") // 👉 "오늘의 소리"라고 읽기
          .accessibilityAddTraits(.isHeader) // 머리말(헤더)로 인식

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
        .accessibilityLabel(speechService.isSpeaking ? "재생 중단 버튼" : "재생 시작 버튼")
        .accessibilityHint(speechService.isSpeaking ? "이중탭하여 재생을 중단합니다" : "이중탭하여 알림을 재생합니다")
        .padding(.bottom, 60)

        // 속도 조절
        HStack(spacing: 48) {
          Button(
            action: { viewModel.decreaseRate() },
            label: {
              Image(systemName: "minus")
                .font(.KoddiBold48)
                .foregroundColor(Color.primaryGreen)
            }
          )
          .accessibilityLabel("재생 속도 감소")
          .accessibilityHint("탭하여 재생 속도를 느리게 합니다")

          // 현재 속도 표시
          Text(String(format: "%.1f x", viewModel.playbackRate))
            .font(.KoddiBold48)
            .foregroundColor(Color.text(colorScheme))
            .monospacedDigit()
            .frame(minWidth: 100)
            .accessibilityElement() // 독립 요소
            .accessibilityLabel("현재 속도 \(String(format: "%.1f", viewModel.playbackRate))배속")
          // 예: "현재 속도 1.0배속"

          Button(
            action: { viewModel.increaseRate() },
            label: {
              Image(systemName: "plus")
                .font(.KoddiBold48)
                .foregroundColor(Color.primaryGreen)
            }
          )
          .accessibilityLabel("재생 속도 증가")
          .accessibilityHint("탭하여 재생 속도를 빠르게 합니다")
        }
        .padding(.bottom, 60)

        VStack(spacing: 16) {
          // "현재 카테고리" 텍스트
          Text("현재 카테고리")
            .font(.KoddiBold28)
            .foregroundColor(Color.text(colorScheme))
            .accessibilityElement()
            .accessibilityLabel("현재 카테고리")

          if viewModel.isLoading {
            Text("불러오는 중...")
              .font(.KoddiExtraBold32)
              .foregroundColor(colorScheme == .dark ? .black : .white)
              .padding(.horizontal, 32)
              .padding(.vertical, 18)
              .frame(width: 360, height: 84)
              .background(
                RoundedRectangle(cornerRadius: 10)
                  .fill(Color.primaryGreen.opacity(0.6))
              )
              .foregroundColor(.white)
              .accessibilityElement()
              .accessibilityLabel("피드를 불러오는 중입니다")
          } else if viewModel.currentCategoryName.isEmpty {
            Text("재생할 피드가 없습니다")
              .font(.KoddiExtraBold32)
              .foregroundColor(colorScheme == .dark ? .black : .white)
              .padding(.horizontal, 32)
              .padding(.vertical, 18)
              .frame(width: 360, height: 84)
              .background(
                RoundedRectangle(cornerRadius: 10)
                  .fill(Color.primaryGreen.opacity(0.6))
              )
              .foregroundColor(.white)
              .accessibilityElement()
              .accessibilityLabel("재생할 피드가 없습니다")
          } else {
            // 현재 카테고리 이름 카드
            Text(viewModel.currentCategoryName)
              .font(.KoddiExtraBold32)
              .foregroundColor(colorScheme == .dark ? .black : .white)
              .padding(.horizontal, 32)
              .padding(.vertical, 18)
              .frame(width: 360, height: 84)
              .background(
                RoundedRectangle(cornerRadius: 10)
                  .fill(Color.primaryGreen)
              )
              .foregroundColor(.white)
              .accessibilityElement()
              .accessibilityLabel(viewModel.currentCategoryName) // 👉 카테고리명만 또렷하게
              .accessibilityHint("현재 재생 중인 카테고리입니다")
          }
        }
        .padding(.bottom, 16)
      }
    }
    .onAppear {
      viewModel.loadHomeFeed()
    }
  }
}

#Preview {
  HomeView()
}
