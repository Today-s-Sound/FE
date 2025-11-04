import Foundation

// MARK: - 공통 API 응답 DTO

/// 서버의 공통 응답 구조
/// 모든 API 응답은 이 구조를 따릅니다: { "errorCode": Int?, "message": String, "result": T }
struct APIResponse<T: Codable>: Codable {
  let errorCode: Int?
  let message: String
  let result: T
}

