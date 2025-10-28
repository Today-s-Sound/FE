import Alamofire
import Foundation
import Moya

enum NetworkKit {
  static func provider<T: TargetType>(userSession: UserSession,
                                      plugins: [PluginType] = []) -> MoyaProvider<T>
  {
    let interceptor = AuthInterceptor(userSession: userSession)
    let session = Session(interceptor: interceptor)
    return MoyaProvider<T>(session: session, plugins: plugins)
  }
}
