import Alamofire
import Foundation
import Moya

final class AuthInterceptor: RequestInterceptor {
  private let userSession: UserSession

  private lazy var refreshProvider: MoyaProvider<AuthAPITarget> = {
    let session = Session(configuration: .default) // no interceptor
    return MoyaProvider<AuthAPITarget>(session: session)
  }()

  private var isRefreshing = false
  private var waiting: [(RetryResult) -> Void] = []
  private let lock = NSLock()

  init(userSession: UserSession) { self.userSession = userSession }

  func adapt(_ urlRequest: URLRequest,
             for session: Session,
             completion: @escaping (Result<URLRequest, Error>) -> Void)
  {
    var req = urlRequest
    let path = req.url?.path ?? ""

    let bypass: Set<String> = [
      "/api/auth/login",
      "/api/auth/refresh"
    ]

    if bypass.contains(path) {
      if req.value(forHTTPHeaderField: "Authorization") != nil {
        req.setValue(nil, forHTTPHeaderField: "Authorization")
      }
      return completion(.success(req))
    }

    if !userSession.accessToken.isEmpty {
      req.setValue("Bearer \(userSession.accessToken)", forHTTPHeaderField: "Authorization")
    }
    completion(.success(req))
  }

  func retry(_ request: Request,
             for session: Session,
             dueTo error: Error,
             completion: @escaping (RetryResult) -> Void)
  {
    let path = request.request?.url?.path ?? "nil"
    let status = request.response?.statusCode ?? -1

    if path == "/api/auth/refresh" {
      completion(.doNotRetry); return
    }

    guard status == 401 || status == 403 || status == 419 else {
      completion(.doNotRetry); return
    }

    guard userSession.autoLogin, !userSession.refreshToken.isEmpty else {
      DispatchQueue.main.async { self.userSession.clear() }
      completion(.doNotRetry)
      return
    }

    lock.lock()
    if isRefreshing {
      waiting.append(completion)
      lock.unlock()
      return
    }
    isRefreshing = true
    waiting.append(completion)
    lock.unlock()

    refreshProvider.request(.refresh(refreshToken: userSession.refreshToken)) { [weak self] result in
      guard let self else { return }
      var queuedResult: RetryResult = .doNotRetry

      switch result {
      case let .success(res):
        if (200 ..< 300).contains(res.statusCode),
           let dto = try? JSONDecoder().decode(RefreshResponseDTO.self, from: res.data),
           dto.isSuccess, let data = dto.data
        {
          DispatchQueue.main.async {
            self.userSession.accessToken = data.accessToken
            self.userSession.refreshToken = data.refreshToken
          }
          queuedResult = .retry
        } else {
          DispatchQueue.main.async { self.userSession.clear() }
        }

      case .failure:
        DispatchQueue.main.async { self.userSession.clear() }
      }

      lock.lock()
      let queued = waiting
      waiting.removeAll()
      isRefreshing = false
      lock.unlock()

      queued.forEach { $0(queuedResult) }
    }
  }
}
