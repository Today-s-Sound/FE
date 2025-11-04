import Foundation

// MARK: - Keyword Response Models

/// 키워드 결과 데이터
struct KeywordsResult: Codable {
  let keywords: [KeywordItem]
}

/// 키워드 목록 응답
typealias KeywordsResponse = APIResponse<KeywordsResult>

extension KeywordsResponse {
  // 편의 속성: result.keywords를 keywords로 접근
  var keywords: [KeywordItem] {
    result.keywords
  }
}

