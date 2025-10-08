//
//  AlertCardView.swift
//  today-s-sound
//
//  Created by Assistant on 12/19/24.
//

import SwiftUI

struct AlertCardView: View {
    let alert: Alert
    let colorScheme: ColorScheme
    
    private var cardColor: Color {
        alert.isUrgent ? .urgentPink : .primaryGreen
    }
    
    private var buttonBackgroundColor: Color {
        Color.buttonBackground(colorScheme)
    }

    var body: some View {
        
        VStack(spacing: 20) {
            // 상단: 타이틀과 아이콘
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: alert.isUrgent ? "bell.fill" : "doc.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(alert.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Text("2시간 전")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
            }

            // 하단: 음성으로 듣기 버튼
            Button(action: {
                SpeechService.shared.speak(text: alert.title)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.text(colorScheme))
                    Text("음성으로 듣기")
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
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardColor)
                .shadow(color: .black15, radius: 8, x: 0, y: 4)
        )
    }
}

struct AlertCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            AlertCardView(
                alert: Alert(
                    id: UUID(),
                    title: "일이삼사오육칠팔",
                    content: "공지 내용 예시",
                    date: Date().addingTimeInterval(-7200),
                    isUrgent: true
                ),
                colorScheme: .light
            )
            
            AlertCardView(
                alert: Alert(
                    id: UUID(),
                    title: "잡코리아 채용 공고",
                    content: "채용 소식",
                    date: Date().addingTimeInterval(-10800),
                    isUrgent: false
                ),
                colorScheme: .dark
            )
        }
        .padding()
    }
}
