import SwiftUI

private struct TabBarForegroundUpdater: UIViewControllerRepresentable {
  let theme: AppTheme

  func makeUIViewController(context: Context) -> UIViewController {
    let vc = UIViewController()
    vc.view.backgroundColor = .clear
    return vc
  }

  func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    guard let tabBar = uiViewController.tabBarController?.tabBar else { return }

    let selectedColor = UIColor(Color.primaryGreen)

    let unselectedColor: UIColor = (theme == .highContrast)
      ? UIColor(white: 1.0, alpha: 0.85)
      : UIColor(Color.primaryGrey)

    tabBar.tintColor = selectedColor
    tabBar.unselectedItemTintColor = unselectedColor

    tabBar.items?.forEach { item in
      item.setTitleTextAttributes([.foregroundColor: unselectedColor], for: .normal)
      item.setTitleTextAttributes([.foregroundColor: selectedColor], for: .selected)

      item.image = item.image?.withRenderingMode(.alwaysTemplate)
      item.selectedImage = item.selectedImage?.withRenderingMode(.alwaysTemplate)
    }
  }
}

struct MainView: View {
  private enum Tab: Hashable {
    case home, feed, notifications, settings
  }

  @State private var selectedTab: Tab = .home
  @EnvironmentObject private var appTheme: AppThemeManager

  var body: some View {
    let theme = appTheme.theme

    TabView(selection: $selectedTab) {
      HomeView()
        .tabItem { Label("홈", systemImage: "play.house.fill") }
        .tag(Tab.home)

      FeedView()
        .tabItem { Label("피드", systemImage: "text.bubble.fill") }
        .tag(Tab.feed)

      NotificationListView()
        .tabItem { Label("알림", systemImage: "bell.fill") }
        .tag(Tab.notifications)

      SettingsView()
        .tabItem { Label("관리", systemImage: "gearshape.fill") }
        .tag(Tab.settings)
    }
    .tint(Color.primaryGreen)
    .background(TabBarForegroundUpdater(theme: theme).frame(width: 0, height: 0))
  }
}

struct MainView_Previews: PreviewProvider {
  private static var normalThemeManager: AppThemeManager {
    let m = AppThemeManager()
    m.theme = .normal
    return m
  }

  private static var highContrastThemeManager: AppThemeManager {
    let m = AppThemeManager()
    m.theme = .highContrast
    return m
  }

  static var previews: some View {
    Group {
      MainView()
        .environmentObject(normalThemeManager)
        .previewDisplayName("Theme: Normal")

      MainView()
        .environmentObject(highContrastThemeManager)
        .previewDisplayName("Theme: HighContrast")
    }
  }
}
