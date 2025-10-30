import AVFoundation
import Foundation

class SpeechService {
  static let shared = SpeechService()
  private let synthesizer = AVSpeechSynthesizer()

  private init() {}

  func speak(text: String, language: String = "ko-KR") {
    let utterance = AVSpeechUtterance(string: text)
    utterance.voice = AVSpeechSynthesisVoice(language: language)

    // Stop any speaking in progress before starting a new one
    if synthesizer.isSpeaking {
      synthesizer.stopSpeaking(at: .immediate)
    }

    synthesizer.speak(utterance)
  }

  func stop() {
    synthesizer.stopSpeaking(at: .immediate)
  }
}
