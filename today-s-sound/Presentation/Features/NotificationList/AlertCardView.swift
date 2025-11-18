//
//  AlertCardView.swift
//  today-s-sound
//
//  Created by Assistant on 12/19/24.
//

import Combine
import SwiftUI

struct AlertCardView: View {
  let alert: Alert?
  let alarm: AlarmItem?
  let colorScheme: ColorScheme

  @State private var isPlaying: Bool = false
  @State private var currentSummaryIndex: Int = 0
  @State private var cancellables = Set<AnyCancellable>()

  // Alert 또는 AlarmItem 중 하나만 있어야 함
  init(alert: Alert? = nil, alarm: AlarmItem? = nil, colorScheme: ColorScheme) {
    self.alert = alert
    self.alarm = alarm
    self.colorScheme = colorScheme
  }

  private var cardColor: Color {
    if let alert {
      return alert.isUrgent ? .urgentPink : .primaryGreen
    } else if let alarm {
      // AlarmItem의 isUrgent 필드로 긴급 여부 판단
      return (alarm.isUrgent ?? false) ? .urgentPink : .primaryGreen
    }
    return .primaryGreen
  }

  private var title: String {
    alert?.title ?? alarm?.alias ?? ""
  }

  private var timeText: String {
    alert.map { _ in "2시간 전" } ?? alarm?.timeAgo ?? ""
  }

  private var summaries: [String] {
    alarm?.summaries.map(\.summary) ?? []
  }

  private var isUrgent: Bool {
    if let alert {
      return alert.isUrgent
    } else if let alarm {
      return alarm.isUrgent ?? false
    }
    return false
  }

  private var buttonBackgroundColor: Color {
    Color.buttonBackground(colorScheme)
  }

  var body: some View {
    VStack(spacing: 20) {
      // 상단: 타이틀과 아이콘
      HStack(alignment: .top, spacing: 12) {
        Image(isUrgent ? "mail" : "notice")
              .resizable()
              .scaledToFit()
              .frame(width: 48, height: 48)
              .foregroundColor(colorScheme == .dark ? .black : .white)
          .accessibilityHidden(true) // 아이콘은 시각적 장식이므로 숨김

        VStack(alignment: .leading, spacing: 8) {
          Text(title)
            .font(.KoddiExtraBold32)
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
            .accessibilityAddTraits(.isHeader) // 헤더로 인식
            .accessibilityLabel(title)

          Text(timeText)
            .font(.KoddiExtraBold28)
            .foregroundColor(colorScheme == .dark ? .black : .white)
            .accessibilityLabel("\(timeText)에 받은 알림")
        }

        Spacer()
      }

      // 하단: 음성으로 듣기 버튼
      Button(action: {
          /*
        if isPlaying {
          // 재생 중단
          SpeechService.shared.stop()
          isPlaying = false
          currentSummaryIndex = 0
          cancellables.removeAll()

          // VoiceOver 알림
          UIAccessibility.post(notification: .announcement, argument: "재생이 중단되었습니다")
           
        } else {
          // 재생 시작
          playAllSummaries()

          // 재생 시작 VoiceOver 알림
          let summaryCount = summaries.count
          if summaryCount > 0 {
            UIAccessibility.post(notification: .announcement, argument: "\(summaryCount)개의 내용을 재생합니다")
          } else {
            UIAccessibility.post(notification: .announcement, argument: "알림 내용을 재생합니다")
          }
        }
        */
      }, label: {
        HStack(spacing: 8) {
          Image(systemName: isPlaying ? "stop.circle.fill" : "speaker.wave.2.fill")
            .font(.system(size: 18))
            .foregroundStyle(isPlaying ? .red : Color.text(colorScheme))
            .accessibilityHidden(true) // 아이콘은 숨김, 텍스트로 전달

          Text(isPlaying ? "재생 중단" : "음성으로 듣기")
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(Color.text(colorScheme))
        }
        .foregroundColor(Color.buttonBackground(colorScheme))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
          RoundedRectangle(cornerRadius: 12)
            .fill(buttonBackgroundColor)
        )
      })
      .accessibilityLabel(accessibilityButtonLabel)
      .accessibilityHint(accessibilityButtonHint)
      .accessibilityValue(accessibilityButtonValue)
      .accessibilityAddTraits(isPlaying ? .isSelected : [])
    }
    .padding(24)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(cardColor)
        .shadow(color: .black15, radius: 8, x: 0, y: 4)
    )
    .accessibilityElement(children: .combine) // 카드를 하나의 요소로 그룹화
    .accessibilityLabel(accessibilityCardLabel)
  }

  // MARK: - 접근성 속성

  private var accessibilityCardLabel: String {
    let typeText = isUrgent ? "긴급 알림" : "알림"
    return "\(typeText), \(title), \(timeText)"
  }

  private var accessibilityButtonLabel: String {
    isPlaying ? "재생 중단 버튼" : "음성으로 듣기 버튼"
  }

  private var accessibilityButtonHint: String {
    if isPlaying {
      return "이중탭하여 재생을 중단합니다"
    } else {
      let count = summaries.count
      if count > 0 {
        return "이중탭하여 \(count)개의 알림 내용을 음성으로 들을 수 있습니다"
      } else {
        return "이중탭하여 알림 내용을 음성으로 들을 수 있습니다"
      }
    }
  }

  private var accessibilityButtonValue: String {
    if isPlaying {
      let total = summaries.count
      if total > 0 {
        return "재생 중, \(currentSummaryIndex + 1)번째 내용 재생 중, 전체 \(total)개"
      } else {
        return "재생 중"
      }
    } else {
      let count = summaries.count
      if count > 0 {
        return "대기 중, \(count)개의 내용이 있습니다"
      } else {
        return "대기 중"
      }
    }
  }

  /*
  // MARK: - 음성 재생 함수
  private func playAllSummaries() {
    guard let alarm, !alarm.summaries.isEmpty else {
      // AlarmItem이 없으면 Alert의 title만 재생
      if let alert {
        SpeechService.shared.speak(text: alert.title)
        isPlaying = true

        // 재생 완료 감지
        SpeechService.shared.didFinishSpeaking
          .sink { [self] _ in
            isPlaying = false
          }
          .store(in: &cancellables)
      }
      return
    }

    // 첫 번째 summary 재생
    currentSummaryIndex = 0
    isPlaying = true
    playSummary(at: 0)
  }

  private func playSummary(at index: Int) {
    guard let alarm,
          index < alarm.summaries.count
    else {
      // 모든 summary 재생 완료
      isPlaying = false
      currentSummaryIndex = 0
      cancellables.removeAll()

      // VoiceOver 알림: 재생 완료
      UIAccessibility.post(notification: .announcement, argument: "모든 내용 재생이 완료되었습니다")
      return
    }

    // 중복 재생 방지: 이미 다른 summary를 재생 중이면 리턴
    guard currentSummaryIndex == index || !SpeechService.shared.isSpeaking else {
      print("⚠️ 이미 재생 중입니다. 중복 재생 방지: 현재 index=\(currentSummaryIndex), 요청된 index=\(index)")
      return
    }

    // 이전 cancellable 정리
    cancellables.removeAll()

    let summary = alarm.summaries[index]
    currentSummaryIndex = index

    // 순서 안내 음성 재생 (예: "첫 번째 내용", "두 번째 내용")
    let orderText = getOrderText(index: index, total: alarm.summaries.count)
    let fullText = "\(orderText). \(summary.summary)"

    // 재생 시작 전에 중복 체크
    guard !SpeechService.shared.isSpeaking else {
      print("⚠️ SpeechService가 이미 재생 중입니다. 중복 재생 방지")
      return
    }

    // 재생 시작
    SpeechService.shared.speak(text: fullText)

    // VoiceOver 알림: 현재 재생 중인 내용
    let total = alarm.summaries.count
    UIAccessibility.post(notification: .announcement, argument: "\(index + 1)번째 내용 재생 중, 전체 \(total)개 중")

    // 재생 완료 감지 (index 검증으로 중복 방지)
    let cancellable = SpeechService.shared.didFinishSpeaking
      .sink(receiveValue: { [self] _ in
        // 현재 재생 중인 index가 변경되었으면 리턴 (중복 방지)
        guard currentSummaryIndex == index else {
          print("⚠️ 재생 중 index 변경됨. 무시: 예상=\(index), 현재=\(currentSummaryIndex)")
          return
        }

        // 다음 summary 재생
        let nextIndex = index + 1
        if nextIndex < alarm.summaries.count {
          // 약간의 딜레이 후 다음 재생
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 딜레이 후에도 여전히 같은 index인지 확인
            if currentSummaryIndex == index {
              playSummary(at: nextIndex)
            }
          }
        } else {
          // 모두 재생 완료
          isPlaying = false
          currentSummaryIndex = 0
          cancellables.removeAll()

          // VoiceOver 알림: 재생 완료
          UIAccessibility.post(notification: .announcement, argument: "모든 내용 재생이 완료되었습니다")
        }
      })

    cancellable.store(in: &cancellables)
  }

  // MARK: - 순서 텍스트 생성

  private func getOrderText(index: Int, total: Int) -> String {
    let numbers = ["첫", "두", "세", "네", "다섯", "여섯", "일곱", "여덟", "아홉", "열"]

    if index < numbers.count {
      return "\(numbers[index]) 번째 내용"
    } else {
      // 10개 이상일 경우 숫자로 표기
      return "\(index + 1)번째 내용"
    }
  }
  */
}

struct AlertCardView_Previews: PreviewProvider {
  private static let sampleAlert = Alert(
    id: UUID(),
    title: "긴급 공지: 서비스 점검 안내",
    content: "오늘 밤 11시부터 자정까지 점검이 진행됩니다.",
    date: Date().addingTimeInterval(-7200),
    isUrgent: true
  )

  private static let sampleAlarm = AlarmItem(
    alias: "접근성 블로그",
    timeAgo: "3분 전",
    summaries: [
      SummaryItem(id: 1, summary: "애플이 새로운 보이스오버 기능을 발표했습니다.", updatedAt: "2024-12-19T09:00:00Z"),
      SummaryItem(id: 2, summary: "iOS 18에서 접근성 옵션이 대폭 개선됩니다.", updatedAt: "2024-12-19T09:05:00Z")
    ],
    isUrgent: false
  )

  static var previews: some View {
    Group {
      AlertCardView(alert: sampleAlert, colorScheme: .light)
        .padding()
        .previewDisplayName("Alert - Light")

      AlertCardView(alarm: sampleAlarm, colorScheme: .dark)
        .padding()
        .background(Color.black)
        .previewDisplayName("Alarm - Dark")
    }
    .previewLayout(.sizeThatFits)
  }
}
