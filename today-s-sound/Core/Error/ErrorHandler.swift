//
//  ErrorHandler.swift
//  today-s-sound
//
//  Created for code review improvements
//

import Foundation

/// 네트워크 에러를 사용자 친화적인 메시지로 변환하는 유틸리티
struct ErrorHandler {
  /// NetworkError를 사용자에게 표시할 메시지로 변환
  static func userFacingMessage(from error: NetworkError) -> String {
    switch error {
    case let .serverError(statusCode):
      return "서버 오류 (상태: \(statusCode))"
    case .decodingFailed:
      return "응답 처리 실패"
    case let .requestFailed(requestError):
      return "요청 실패: \(requestError.localizedDescription)"
    case .invalidURL:
      return "잘못된 URL"
    case .unknown:
      return "알 수 없는 오류"
    }
  }
  
  /// 에러를 로깅하고 사용자 메시지 반환
  static func handleError(_ error: NetworkError, context: String = "") -> String {
    let message = userFacingMessage(from: error)
    let logContext = context.isEmpty ? "에러 발생" : context
    print("❌ \(logContext): \(message)")
    return message
  }
}
