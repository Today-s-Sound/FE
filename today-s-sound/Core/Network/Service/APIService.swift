import Combine
import CombineMoya
import Foundation
import Moya

protocol APIServiceType {
  func request<T: Decodable>(_ target: some TargetType) -> AnyPublisher<T, NetworkError>
  func registerAnonymous(request: RegisterAnonymousRequest) -> AnyPublisher<RegisterAnonymousResponse, NetworkError>
  func withdrawUser(userId: String, deviceSecret: String) -> AnyPublisher<Void, NetworkError>
  func updateFCMToken(userId: String, deviceSecret: String, fcmToken: String) -> AnyPublisher<Void, NetworkError>
  func getSubscriptions(
    userId: String, deviceSecret: String, page: Int, size: Int
  ) -> AnyPublisher<SubscriptionListResponse, NetworkError>
  func createSubscription(
    userId: String, deviceSecret: String, request: CreateSubscriptionRequest
  ) -> AnyPublisher<CreateSubscriptionResponse, NetworkError>
  func updateSubscription(
    userId: String, deviceSecret: String, subscriptionId: Int64, request: UpdateSubscriptionRequest
  ) -> AnyPublisher<Void, NetworkError>
  func deleteSubscription(
    userId: String, deviceSecret: String, subscriptionId: Int64
  ) -> AnyPublisher<DeleteSubscriptionResponse, NetworkError>
  func getAlarms(
    userId: String, deviceSecret: String, page: Int, size: Int
  ) -> AnyPublisher<AlarmListResponse, NetworkError>
  func deleteSummary(userId: String, deviceSecret: String, summaryId: Int64) -> AnyPublisher<Void, NetworkError>
  func getKeywords() -> AnyPublisher<KeywordsResponse, NetworkError>
  func getURLs() -> AnyPublisher<URLsResponse, NetworkError>
  func getHomeFeed(
    userId: String, deviceSecret: String
  ) -> AnyPublisher<HomeFeedResponse, NetworkError>
  func getFeeds(
    userId: String, deviceSecret: String, page: Int, size: Int
  ) -> AnyPublisher<FeedListResponse, NetworkError>
}

class APIService: APIServiceType {
  private let userProvider: MoyaProvider<UserAPI>
  private let authProvider: MoyaProvider<AuthAPITarget>
  private let subscriptionProvider: MoyaProvider<SubscriptionAPI>
  private let alarmProvider: MoyaProvider<AlarmAPI>
  private let keywordProvider: MoyaProvider<KeywordAPI>
  private let urlProvider: MoyaProvider<URLAPI>
  private let feedProvider: MoyaProvider<FeedAPI>

  init(userSession: UserSession = UserSession()) {
    #if DEBUG
      // 개발 모드에서는 로깅 플러그인 추가
      let logger = NetworkLoggerPlugin(configuration: .init(
        logOptions: .verbose
      ))
      userProvider = NetworkKit.provider(userSession: userSession, plugins: [logger])
      authProvider = NetworkKit.provider(userSession: userSession, plugins: [logger])
      subscriptionProvider = NetworkKit.provider(userSession: userSession, plugins: [logger])
      alarmProvider = NetworkKit.provider(userSession: userSession, plugins: [logger])
      keywordProvider = NetworkKit.provider(userSession: userSession, plugins: [logger])
      urlProvider = NetworkKit.provider(userSession: userSession, plugins: [logger])
      feedProvider = NetworkKit.provider(userSession: userSession, plugins: [logger])
    #else
      userProvider = NetworkKit.provider(userSession: userSession)
      authProvider = NetworkKit.provider(userSession: userSession)
      subscriptionProvider = NetworkKit.provider(userSession: userSession)
      alarmProvider = NetworkKit.provider(userSession: userSession)
      keywordProvider = NetworkKit.provider(userSession: userSession)
      urlProvider = NetworkKit.provider(userSession: userSession)
      feedProvider = NetworkKit.provider(userSession: userSession)
    #endif
  }

  // MARK: - Generic Request

  func request<T: Decodable>(_ target: some TargetType) -> AnyPublisher<T, NetworkError> {
    Fail<T, NetworkError>(error: .requestFailed(NSError(domain: "NotImplemented", code: -1)))
      .eraseToAnyPublisher()
  }

  // MARK: - 공통 응답 처리 헬퍼

  /// 공통 응답 처리: 상태 코드 체크, 디코딩, 에러 처리
  private func handleResponse<T: Decodable>(
    _ response: Response,
    decodeTo type: T.Type,
    debugLabel: String = ""
  ) -> AnyPublisher<T, NetworkError> {
    Just(response)
      .tryMap { response -> Data in
        // 상태 코드 체크
        guard (200 ... 299).contains(response.statusCode) else {
          throw NetworkError.serverError(statusCode: response.statusCode)
        }

        // 🐛 디버깅: 서버 응답 출력
        #if DEBUG
          if let jsonString = String(data: response.data, encoding: .utf8) {
            let label = debugLabel.isEmpty ? "서버 응답" : debugLabel
            print("📥 \(label) (Raw JSON):")
            print(jsonString)
          }
        #endif

        return response.data
      }
      .decode(type: type, decoder: JSONDecoder())
      .mapError { error -> NetworkError in
        // 🐛 디버깅: 디코딩 에러 상세 출력
        #if DEBUG
          if let decodingError = error as? DecodingError {
            print("❌ 디코딩 에러 발생:")
            switch decodingError {
            case let .keyNotFound(key, context):
              print("  - 키를 찾을 수 없음: \(key.stringValue)")
              print("  - 경로: \(context.codingPath.map(\.stringValue).joined(separator: " -> "))")
              print("  - 설명: \(context.debugDescription)")
            case let .typeMismatch(type, context):
              print("  - 타입 불일치: \(type)")
              print("  - 경로: \(context.codingPath.map(\.stringValue).joined(separator: " -> "))")
              print("  - 설명: \(context.debugDescription)")
              if let underlyingError = context.underlyingError {
                print("  - 근본 원인: \(underlyingError)")
              }
            case let .valueNotFound(type, context):
              print("  - 값을 찾을 수 없음: \(type)")
              print("  - 경로: \(context.codingPath.map(\.stringValue).joined(separator: " -> "))")
            case let .dataCorrupted(context):
              print("  - 데이터 손상")
              print("  - 경로: \(context.codingPath.map(\.stringValue).joined(separator: " -> "))")
            @unknown default:
              print("  - 알 수 없는 디코딩 에러")
            }
          }
        #endif

        if let networkError = error as? NetworkError {
          return networkError
        } else if error is DecodingError {
          return .decodingFailed(error)
        } else {
          return .requestFailed(error)
        }
      }
      .eraseToAnyPublisher()
  }

  // MARK: - User API

  func registerAnonymous(request: RegisterAnonymousRequest) -> AnyPublisher<RegisterAnonymousResponse, NetworkError> {
    userProvider.requestPublisher(.registerAnonymous(request: request))
      .mapError { moyaError -> NetworkError in
        .requestFailed(moyaError)
      }
      .flatMap { [weak self] response -> AnyPublisher<RegisterAnonymousResponse, NetworkError> in
        guard let self else {
          return Fail(error: NetworkError.unknown)
            .eraseToAnyPublisher()
        }
        return handleResponse(response, decodeTo: RegisterAnonymousResponse.self, debugLabel: "익명 사용자 등록 응답")
      }
      .eraseToAnyPublisher()
  }

  func withdrawUser(userId: String, deviceSecret: String) -> AnyPublisher<Void, NetworkError> {
    userProvider.requestPublisher(.withdraw(userId: userId, deviceSecret: deviceSecret))
      .mapError { moyaError -> NetworkError in
        .requestFailed(moyaError)
      }
      .tryMap { response in
        // 상태 코드만 확인 (200-299면 성공)
        guard (200 ... 299).contains(response.statusCode) else {
          throw NetworkError.serverError(statusCode: response.statusCode)
        }

        #if DEBUG
          print("✅ 사용자 탈퇴 성공")
        #endif

        return ()
      }
      .mapError { error -> NetworkError in
        if let networkError = error as? NetworkError {
          return networkError
        } else {
          return .requestFailed(error)
        }
      }
      .eraseToAnyPublisher()
  }

  func updateFCMToken(userId: String, deviceSecret: String, fcmToken: String) -> AnyPublisher<Void, NetworkError> {
    let request = UpdateFCMTokenRequest(fcmToken: fcmToken)
    return userProvider.requestPublisher(.updateFCMToken(userId: userId, deviceSecret: deviceSecret, request: request))
      .mapError { moyaError -> NetworkError in
        .requestFailed(moyaError)
      }
      .tryMap { response in
        // 상태 코드만 확인 (200-299면 성공)
        guard (200 ... 299).contains(response.statusCode) else {
          throw NetworkError.serverError(statusCode: response.statusCode)
        }

        #if DEBUG
          print("✅ FCM 토큰 업데이트 성공")
        #endif

        return ()
      }
      .mapError { error -> NetworkError in
        if let networkError = error as? NetworkError {
          return networkError
        } else {
          return .requestFailed(error)
        }
      }
      .eraseToAnyPublisher()
  }

  // MARK: - Subscription API

  func getSubscriptions(
    userId: String, deviceSecret: String, page: Int = 0, size: Int = 10
  ) -> AnyPublisher<SubscriptionListResponse, NetworkError> {
    subscriptionProvider.requestPublisher(.getSubscriptions(
      userId: userId,
      deviceSecret: deviceSecret,
      page: page,
      size: size
    ))
    .mapError { moyaError -> NetworkError in
      .requestFailed(moyaError)
    }
    .flatMap { [weak self] response -> AnyPublisher<SubscriptionListResponse, NetworkError> in
      guard let self else {
        return Fail(error: NetworkError.unknown)
          .eraseToAnyPublisher()
      }
      return handleResponse(response, decodeTo: SubscriptionListResponse.self, debugLabel: "구독 목록 응답")
    }
    .eraseToAnyPublisher()
  }

  func createSubscription(
    userId: String, deviceSecret: String, request: CreateSubscriptionRequest
  ) -> AnyPublisher<CreateSubscriptionResponse, NetworkError> {
    subscriptionProvider.requestPublisher(.createSubscription(
      userId: userId,
      deviceSecret: deviceSecret,
      request: request
    ))
    .mapError { moyaError -> NetworkError in
      .requestFailed(moyaError)
    }
    .flatMap { [weak self] response -> AnyPublisher<CreateSubscriptionResponse, NetworkError> in
      guard let self else {
        return Fail(error: NetworkError.unknown)
          .eraseToAnyPublisher()
      }
      return handleResponse(response, decodeTo: CreateSubscriptionResponse.self, debugLabel: "구독 생성 응답")
    }
    .eraseToAnyPublisher()
  }

  func updateSubscription(
    userId: String, deviceSecret: String, subscriptionId: Int64, request: UpdateSubscriptionRequest
  ) -> AnyPublisher<Void, NetworkError> {
    subscriptionProvider.requestPublisher(.updateSubscription(
      userId: userId,
      deviceSecret: deviceSecret,
      subscriptionId: subscriptionId,
      request: request
    ))
    .mapError { moyaError -> NetworkError in
      .requestFailed(moyaError)
    }
    .tryMap { response in
      guard (200 ... 299).contains(response.statusCode) else {
        throw NetworkError.serverError(statusCode: response.statusCode)
      }

      #if DEBUG
        print("✅ 구독 수정 성공: subscriptionId=\(subscriptionId)")
      #endif

      return ()
    }
    .mapError { error -> NetworkError in
      if let networkError = error as? NetworkError {
        return networkError
      } else {
        return .requestFailed(error)
      }
    }
    .eraseToAnyPublisher()
  }

  // MARK: - Subscription API (Delete)

  func deleteSubscription(
    userId: String, deviceSecret: String, subscriptionId: Int64
  ) -> AnyPublisher<DeleteSubscriptionResponse, NetworkError> {
    subscriptionProvider.requestPublisher(.deleteSubscription(
      userId: userId,
      deviceSecret: deviceSecret,
      subscriptionId: subscriptionId
    ))
    .mapError { moyaError -> NetworkError in
      .requestFailed(moyaError)
    }
    .flatMap { [weak self] response -> AnyPublisher<DeleteSubscriptionResponse, NetworkError> in
      guard let self else {
        return Fail(error: NetworkError.unknown)
          .eraseToAnyPublisher()
      }
      return handleResponse(response, decodeTo: DeleteSubscriptionResponse.self, debugLabel: "구독 삭제 응답")
    }
    .eraseToAnyPublisher()
  }

  // MARK: - Alarm API

  func getAlarms(
    userId: String, deviceSecret: String, page: Int = 0, size: Int = 10
  ) -> AnyPublisher<AlarmListResponse, NetworkError> {
    alarmProvider.requestPublisher(.getAlarms(
      userId: userId,
      deviceSecret: deviceSecret,
      page: page,
      size: size
    ))
    .mapError { moyaError -> NetworkError in
      .requestFailed(moyaError)
    }
    .flatMap { [weak self] response -> AnyPublisher<AlarmListResponse, NetworkError> in
      guard let self else {
        return Fail(error: NetworkError.unknown)
          .eraseToAnyPublisher()
      }
      return handleResponse(response, decodeTo: AlarmListResponse.self, debugLabel: "알림 목록 응답")
    }
    .eraseToAnyPublisher()
  }

  func deleteSummary(userId: String, deviceSecret: String, summaryId: Int64) -> AnyPublisher<Void, NetworkError> {
    alarmProvider.requestPublisher(.deleteSummary(userId: userId, deviceSecret: deviceSecret, summaryId: summaryId))
      .mapError { moyaError -> NetworkError in
        .requestFailed(moyaError)
      }
      .tryMap { response in
        guard (200 ... 299).contains(response.statusCode) else {
          throw NetworkError.serverError(statusCode: response.statusCode)
        }

        #if DEBUG
          print("✅ 알림 삭제 성공: summaryId=\(summaryId)")
        #endif

        return ()
      }
      .mapError { error -> NetworkError in
        if let networkError = error as? NetworkError {
          return networkError
        } else {
          return .requestFailed(error)
        }
      }
      .eraseToAnyPublisher()
  }

  // MARK: - Keyword API

  func getKeywords() -> AnyPublisher<KeywordsResponse, NetworkError> {
    keywordProvider.requestPublisher(.getKeywords)
      .mapError { moyaError -> NetworkError in
        .requestFailed(moyaError)
      }
      .flatMap { [weak self] response -> AnyPublisher<KeywordsResponse, NetworkError> in
        guard let self else {
          return Fail(error: NetworkError.unknown)
            .eraseToAnyPublisher()
        }
        return handleResponse(response, decodeTo: KeywordsResponse.self, debugLabel: "키워드 목록 응답")
      }
      .eraseToAnyPublisher()
  }

  // MARK: - URL API

  func getURLs() -> AnyPublisher<URLsResponse, NetworkError> {
    urlProvider.requestPublisher(.getURLs)
      .mapError { moyaError -> NetworkError in
        .requestFailed(moyaError)
      }
      .flatMap { [weak self] response -> AnyPublisher<URLsResponse, NetworkError> in
        guard let self else {
          return Fail(error: NetworkError.unknown)
            .eraseToAnyPublisher()
        }
        return handleResponse(response, decodeTo: URLsResponse.self, debugLabel: "URL 목록 응답")
      }
      .eraseToAnyPublisher()
  }

  // MARK: - Feed API

  func getHomeFeed(
    userId: String, deviceSecret: String
  ) -> AnyPublisher<HomeFeedResponse, NetworkError> {
    feedProvider.requestPublisher(.getHomeFeed(
      userId: userId,
      deviceSecret: deviceSecret
    ))
    .mapError { moyaError -> NetworkError in
      .requestFailed(moyaError)
    }
    .flatMap { [weak self] response -> AnyPublisher<HomeFeedResponse, NetworkError> in
      guard let self else {
        return Fail(error: NetworkError.unknown)
          .eraseToAnyPublisher()
      }
      return handleResponse(response, decodeTo: HomeFeedResponse.self, debugLabel: "홈 피드 응답")
    }
    .eraseToAnyPublisher()
  }

  func getFeeds(
    userId: String, deviceSecret: String, page: Int = 0, size: Int = 10
  ) -> AnyPublisher<FeedListResponse, NetworkError> {
    feedProvider.requestPublisher(.getFeeds(
      userId: userId,
      deviceSecret: deviceSecret,
      page: page,
      size: size
    ))
    .mapError { moyaError -> NetworkError in
      .requestFailed(moyaError)
    }
    .flatMap { [weak self] response -> AnyPublisher<FeedListResponse, NetworkError> in
      guard let self else {
        return Fail(error: NetworkError.unknown)
          .eraseToAnyPublisher()
      }
      return handleResponse(response, decodeTo: FeedListResponse.self, debugLabel: "피드 목록 응답")
    }
    .eraseToAnyPublisher()
  }
}
