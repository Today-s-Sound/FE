import SwiftUI
import UIKit

struct MainView: View {
  private enum Tab: Hashable {
    case home
    case feed
    case notifications
    case settings
  }

  @State private var selectedTab: Tab = .home
  @EnvironmentObject var appTheme: AppThemeManager

  var body: some View {
    TabView(selection: $selectedTab) {
      HomeView()
        .tabItem {
          VStack {
            Image(systemName: "play.house.fill")
              .accessibilityHidden(true) // 아이콘은 숨기고
            Text("홈") // 이름만 읽히게
          }
        }
        .tag(Tab.home)

      FeedView()
        .tabItem {
          VStack {
            Image(systemName: "text.bubble.fill")
              .accessibilityHidden(true)
            Text("피드")
          }
        }
        .tag(Tab.feed)

      NotificationListView()
        .tabItem {
          VStack {
            Image(systemName: "bell.fill")
              .accessibilityHidden(true)
            Text("알림")
          }
        }
        .tag(Tab.notifications)

      SettingsView()
        .tabItem {
          VStack {
            Image(systemName: "gearshape.fill")
              .accessibilityHidden(true)
            Text("관리")
          }
        }
        .tag(Tab.settings)
    }
    .tint(appTheme.isHighContrast ? .white : .primaryGreen)
    .onAppear {
      setupTabBarAppearance()
    }
    .onChange(of: appTheme.theme) { _ in
      setupTabBarAppearance()
    }
    .onChange(of: selectedTab) { _ in
      // 탭이 변경될 때마다 TabBar appearance 재설정
      DispatchQueue.main.async {
        setupTabBarAppearance()
      }
    }
  }

  private func setupTabBarAppearance() {
    let appearance = UITabBarAppearance()
    
    // TabBar 배경색을 앱 테마에 맞게 설정
    if appTheme.isHighContrast {
      // 고대비 모드: 검은 배경
      appearance.configureWithOpaqueBackground()
      appearance.backgroundColor = .black
      
      // 선택되지 않은 탭 아이템 색상
      appearance.stackedLayoutAppearance.normal.iconColor = .white.withAlphaComponent(0.6)
      appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
        .foregroundColor: UIColor.white.withAlphaComponent(0.6)
      ]
      
      // 선택된 탭 아이템 색상
      appearance.stackedLayoutAppearance.selected.iconColor = .white
      appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
        .foregroundColor: UIColor.white
      ]
    } else {
      // 일반 모드: 흰 배경
      appearance.configureWithOpaqueBackground()
      appearance.backgroundColor = .white
      
      // 선택되지 않은 탭 아이템 색상
      appearance.stackedLayoutAppearance.normal.iconColor = .black.withAlphaComponent(0.6)
      appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
        .foregroundColor: UIColor.black.withAlphaComponent(0.6)
      ]
      
      // 선택된 탭 아이템 색상
      appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.primaryGreen)
      appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
        .foregroundColor: UIColor(Color.primaryGreen)
      ]
    }
    
    UITabBar.appearance().standardAppearance = appearance
    if #available(iOS 15.0, *) {
      UITabBar.appearance().scrollEdgeAppearance = appearance
    }
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}
