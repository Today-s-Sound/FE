import Foundation

enum Config {
  static var baseURL: String {
    #if DEBUG
      return "https://dev-your-api-url.com"
    #else
      return "https://your-api-url.com"
    #endif
  }
}
