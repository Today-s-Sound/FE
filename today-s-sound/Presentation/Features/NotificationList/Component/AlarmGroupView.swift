//
//  AlarmGroupView.swift
//  today-s-sound
//
//  알림 그룹을 표시하는 카드 컴포넌트
//

import SwiftUI
import Combine

struct AlarmGroupView: View {
  let alarm: AlarmItem
  let colorScheme: ColorScheme
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // 헤더: 구독 이름 + 시간
      HStack {
        Text(alarm.alias)
          .font(.custom("KoddiUD OnGothic Bold", size: 18))
          .foregroundColor(Color.text(colorScheme))
        
        Spacer()
        
        Text(alarm.timeAgo)
          .font(.system(size: 13))
          .foregroundColor(Color.secondaryText(colorScheme))
      }
      
      // 구분선
      Divider()
        .background(Color.border(colorScheme))
      
      // 요약 목록
      VStack(alignment: .leading, spacing: 8) {
        ForEach(alarm.summaries) { summary in
          SummaryRowView(summary: summary, colorScheme: colorScheme)
        }
      }
    }
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.secondaryBackground(colorScheme))
        .shadow(color: .black5, radius: 4, x: 0, y: 2)
    )
  }
}

struct SummaryRowView: View {
  let summary: SummaryItem
  let colorScheme: ColorScheme
  
  @State private var isPlaying: Bool = false
  @State private var cancellable: AnyCancellable?
  
  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      // 불릿 포인트
      Circle()
        .fill(Color.primaryGreen)
        .frame(width: 6, height: 6)
        .padding(.top, 6)
      
      // 요약 텍스트
      Text(summary.summary)
        .font(.system(size: 15))
        .foregroundColor(Color.text(colorScheme))
        .fixedSize(horizontal: false, vertical: true)
      
      Spacer()
      
      // 재생 버튼
      Button(action: {
        if isPlaying {
          // 재생 중단
          SpeechService.shared.stop()
          isPlaying = false
          cancellable?.cancel()
        } else {
          // 재생 시작
          SpeechService.shared.speak(text: summary.summary)
          isPlaying = true
          
          // 재생 완료 알림 구독
          cancellable = SpeechService.shared.didFinishSpeaking
            .sink { _ in
              isPlaying = false
            }
        }
      }) {
        Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
          .font(.system(size: 24))
          .foregroundColor(isPlaying ? .red : Color.primaryGreen)
      }
      .buttonStyle(.plain)
      .padding(.top, 2)
    }
  }
}

// MARK: - Preview

#if DEBUG
struct AlarmGroupView_Previews: PreviewProvider {
  static var previews: some View {
    VStack(spacing: 16) {
      AlarmGroupView(
        alarm: AlarmItem(
          alias: "동국대학교 장애학생지원센터",
          timeAgo: "2시간 전",
          summaries: [
            SummaryItem(id: 1, summary: "2025년 1학기 학습지원 도우미 모집 안내", updatedAt: "2025-11-01T10:00:00Z"),
            SummaryItem(id: 2, summary: "장애학생 학습 보조기기 대여 신청 접수 중", updatedAt: "2025-11-01T11:00:00Z")
          ],
          isUrgent: false
        ),
        colorScheme: .light
      )
      
      AlarmGroupView(
        alarm: AlarmItem(
          alias: "서울시 긴급재난문자",
          timeAgo: "5분 전",
          summaries: [
            SummaryItem(id: 3, summary: "강남구 일대 호우 특보 발령", updatedAt: "2025-11-01T11:50:00Z")
          ],
          isUrgent: true
        ),
        colorScheme: .dark
      )
    }
    .padding()
  }
}
#endif

