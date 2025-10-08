
import SwiftUI

struct NotificationListView: View {
    @StateObject private var viewModel = NotificationListViewModel()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .dark ? Color.black : Color(white: 0.95))
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()
                    // 타이틀
                    Text("최근 알림")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)

                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(viewModel.alerts) { alert in
                                AlertCardView(alert: alert, colorScheme: colorScheme)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct AlertCardView: View {
    let alert: Alert
    let colorScheme: ColorScheme
    let customPink = Color(red: 1.0, green: 0.298, blue: 0.729, opacity: 1.0)
    let customGreen = Color(red: 0 / 255, green: 223 / 255, blue: 119 / 255)
    
    private var cardColor: Color {
        alert.isUrgent ? customPink : customGreen
    }
    
    private var buttonBackgroundColor: Color {
        colorScheme == .dark ? .black : .white
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
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                    Text("음성으로 듣기")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                .foregroundColor(colorScheme == .dark ? .black : .white)
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
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
    }
}

struct NotificationListView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationListView()
    }
}
