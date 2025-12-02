import Foundation

enum Config {
  static var baseURL: String {
    #if DEBUG
      // return "https://www.today-sound.com"
      return "http://localhost:8080" // 개발 서버
    #else
      return "https://api.todays-sound.com" // 운영 서버
    #endif
  }
}
