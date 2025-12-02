import AVFoundation
import Combine
import Foundation

class SpeechService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
  static let shared = SpeechService()
  private let synthesizer = AVSpeechSynthesizer()

  // 재생 완료 알림을 위한 Publisher
  let didFinishSpeaking = PassthroughSubject<Void, Never>()

  @Published var isSpeaking: Bool = false

  override private init() {
    super.init()
    synthesizer.delegate = self
  }

  func speak(text: String, language: String = "ko-KR", rate: Float? = nil) {
    // 빈 텍스트 체크
    guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      print("⚠️ SpeechService: 빈 텍스트는 재생할 수 없습니다")
      return
    }

    let utterance = AVSpeechUtterance(string: text)
    utterance.voice = AVSpeechSynthesisVoice(language: language)
    
    // rate가 제공되면 사용, 없으면 기본값 0.5
    // AVSpeechUtterance의 rate는 0.0 ~ 1.0 범위
    // 사용자가 설정한 playbackRate (0.5 ~ 2.0)를 0.0 ~ 1.0 범위로 변환
    if let customRate = rate {
      // 0.5 ~ 2.0 범위를 0.0 ~ 1.0 범위로 선형 매핑
      // 예: 0.5 -> 0.25, 1.0 -> 0.5, 2.0 -> 1.0
      let normalizedRate = Float((customRate - 0.5) / 1.5 * 0.75 + 0.25)
      utterance.rate = min(1.0, max(0.0, normalizedRate))
    } else {
      utterance.rate = 0.5 // 기본값
    }

    // Stop any speaking in progress before starting a new one
    if synthesizer.isSpeaking {
      synthesizer.stopSpeaking(at: .immediate)
      // 중단 이벤트는 didFinishSpeaking으로 전달하지 않음
    }

    isSpeaking = true
    synthesizer.speak(utterance)
  }

  func stop() {
    if synthesizer.isSpeaking {
      synthesizer.stopSpeaking(at: .immediate)
    }
    isSpeaking = false
    // stop() 호출 시에는 didFinishSpeaking 이벤트를 보내지 않음 (의도적 중단)
  }

  // MARK: - AVSpeechSynthesizerDelegate

  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
    // isSpeaking이 true일 때만 완료 이벤트 전송 (중복 방지)
    if isSpeaking {
      isSpeaking = false
      didFinishSpeaking.send()
    }
  }

  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
    isSpeaking = false
    // 취소 시에는 didFinishSpeaking 이벤트를 보내지 않음
  }
}
