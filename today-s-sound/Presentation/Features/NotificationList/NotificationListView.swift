import SwiftUI

struct NotificationListView: View {
  @StateObject private var viewModel = NotificationListViewModel()
  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    NavigationView {
      ZStack {
        Color.background(colorScheme)
          .ignoresSafeArea()

        VStack(spacing: 0) {
          Spacer()
          ScreenMainTitle(text: "최근 알림", colorScheme: colorScheme)

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

struct NotificationListView_Previews: PreviewProvider {
  static var previews: some View {
    NotificationListView()
  }
}
