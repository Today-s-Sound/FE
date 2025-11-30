//
//  AlertCardView.swift
//  today-s-sound
//

import SwiftUI

struct AlertCardView: View {
  let alarm: AlarmItem
  let colorScheme: ColorScheme

  private var cardColor: Color {
    alarm.isUrgent ? .urgentPink : .primaryGreen
  }

  private var buttonBackgroundColor: Color {
    Color.buttonBackground(colorScheme)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      // 상단: 아이콘 + 제목 + 시간
      HStack(alignment: .top, spacing: 12) {
        Image(alarm.isUrgent ? "notice" : "mail")
          .resizable()
          .scaledToFit()
          .frame(width: 48, height: 48)
          .accessibilityHidden(true)

        VStack(alignment: .leading, spacing: 4) {
          Text(alarm.alias)
            .font(.KoddiExtraBold32)
            .foregroundColor(colorScheme == .dark ? .black : .white)
            .multilineTextAlignment(.leading)

          Text(alarm.timeAgo)
            .font(.KoddiExtraBold28)
            .foregroundColor(colorScheme == .dark ? .black : .white)
        }

        Spacer()
      }

      // 하단: (추후 음성 재생 버튼용) 지금은 단순 버튼 UI만
      Button(action: {
        // TODO: 여기서 나중에 TTS/음성 재생 로직 연결
      }, label: {
        HStack(spacing: 20) {
          Image(systemName: "speaker.wave.2")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
            .foregroundStyle(cardColor)
            .accessibilityHidden(true)
            
          Text("음성으로 듣기")
                .font(.KoddiExtraBold32)
            .foregroundColor(Color.text(colorScheme))
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(buttonBackgroundColor)
        )
      })
      .accessibilityLabel("음성으로 듣기 버튼")
      .accessibilityHint("이중탭하여 알림 내용을 음성으로 들을 수 있습니다")
    }
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: 10)
        .fill(cardColor)
    )
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(alarm.isUrgent ? "긴급 알림" : "알림"), \(alarm.alias), \(alarm.timeAgo)")
  }
}

struct AlertCardView_Previews: PreviewProvider {
  private static let sampleAlarm = AlarmItem(
    subscriptionId: 1,
    alias: "접근성 블로그",
    summaryContent: "애플이 새로운 보이스오버 기능을 발표했습니다.",
    timeAgo: "3분 전",
    isUrgent: false
  )

  static var previews: some View {
    Group {
      AlertCardView(alarm: sampleAlarm, colorScheme: .light)
        .padding()
        .previewDisplayName("Alarm - Light")

      AlertCardView(alarm: sampleAlarm, colorScheme: .dark)
        .padding()
        .background(Color.black)
        .previewDisplayName("Alarm - Dark")
    }
    .previewLayout(.sizeThatFits)
  }
}
