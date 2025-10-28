import Foundation
import Moya

protocol APITargetType: TargetType {}

extension APITargetType {
  var baseURL: URL {
    guard let url = URL(string: Config.baseURL) else {
      fatalError("Invalid Base URL")
    }
    return url
  }
}


