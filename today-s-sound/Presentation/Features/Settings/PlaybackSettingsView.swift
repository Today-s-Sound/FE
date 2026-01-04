import SwiftUI

struct PlaybackSettingsView: View {
  @StateObject private var viewModel = PlaybackSettingsViewModel()
  @EnvironmentObject var appTheme: AppThemeManager
  @Environment(\.dismiss) var dismiss

  var body: some View {
    ZStack {
      Color.background(appTheme.theme)
        .ignoresSafeArea()

      VStack(spacing: 0) {
        // 재생 속도 설정
        VStack(alignment: .leading, spacing: 16) {
          Text("재생 속도 설정")
            .font(.KoddiBold20)
            .foregroundColor(Color.primaryGreen)
            .padding(.horizontal, 20)
            .padding(.top, 32)
            .accessibilityAddTraits(.isHeader)

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
            .accessibilityValue("현재 속도 \(String(format: "%.1f", viewModel.playbackRate))배속")
            .accessibilityHint("탭하여 재생 속도를 느리게 합니다")

            Text(String(format: "%.1f x", viewModel.playbackRate))
              .font(.KoddiBold48)
              .foregroundColor(Color.text(appTheme.theme))
              .monospacedDigit()
              .frame(minWidth: 100)
              .accessibilityHidden(true)

            Button(
              action: { viewModel.increaseRate() },
              label: {
                Image(systemName: "plus")
                  .font(.KoddiBold48)
                  .foregroundColor(Color.primaryGreen)
              }
            )
            .accessibilityLabel("재생 속도 증가")
            .accessibilityValue("현재 속도 \(String(format: "%.1f", viewModel.playbackRate))배속")
            .accessibilityHint("탭하여 재생 속도를 빠르게 합니다")
          }
          .frame(maxWidth: .infinity)
          .padding(.horizontal, 20)
          .padding(.bottom, 32)
        }

        Divider()
          .background(Color.border(appTheme.theme))
          .padding(.horizontal, 20)

        Spacer()

        // 저장하기 버튼
        MainButton(
          title: "저장하기",
          theme: appTheme.theme,
          isEnabled: true
        ) {
          viewModel.saveSettings()
          dismiss()
        }
        .accessibilityLabel("저장하기")
        .accessibilityHint("재생 설정을 저장하고 관리 화면으로 돌아갑니다")
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
      }
    }
  }
}

// MARK: - ViewModel

class PlaybackSettingsViewModel: ObservableObject {
  @Published var playbackRate: Double = 1.0

  init() {
    // UserDefaults에서 저장된 재생 속도 불러오기
    playbackRate = UserDefaults.standard.double(forKey: "playbackRate")
    if playbackRate == 0 {
      playbackRate = 1.0 // 기본값
    }
  }

  func increaseRate() {
    playbackRate = min(2.0, (playbackRate * 10 + 1).rounded() / 10)
  }

  func decreaseRate() {
    playbackRate = max(0.5, (playbackRate * 10 - 1).rounded() / 10)
  }

  func saveSettings() {
    UserDefaults.standard.set(playbackRate, forKey: "playbackRate")
    // MainViewModel에도 동기화 (필요한 경우)
    NotificationCenter.default.post(name: NSNotification.Name("PlaybackRateChanged"), object: nil, userInfo: ["rate": playbackRate])
  }
}
