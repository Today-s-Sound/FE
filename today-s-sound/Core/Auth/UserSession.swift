import Foundation

final class UserSession: ObservableObject {
  @Published var accessToken: String = ""
  @Published var refreshToken: String = ""
  @Published var autoLogin: Bool = true

  func clear() {
    accessToken = ""
    refreshToken = ""
  }
}


