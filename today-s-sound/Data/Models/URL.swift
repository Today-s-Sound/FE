import Foundation

// MARK: - URL Response Models

/// URL 목록 응답 (배열 직접 반환 또는 APIResponse 형태)
/// Swagger 문서에 따르면 배열을 직접 반환하지만, 프로젝트 일관성을 위해 APIResponse로 처리
typealias URLsResponse = APIResponse<[URLItem]>

extension URLsResponse {
  // 편의 속성: result를 urls로 접근
  var urls: [URLItem] {
    result
  }
}

/// 개별 URL 아이템
struct URLItem: Codable, Identifiable {
  let id: Int64
  let link: String
  let title: String
}
