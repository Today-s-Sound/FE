//
//  PaginationState.swift
//  today-s-sound
//
//  Created for code review improvements
//

import Foundation

/// 페이지네이션 상태를 관리하는 클래스
/// 여러 ViewModel에서 중복되는 페이지네이션 로직을 공통화
final class PaginationState {
  private(set) var currentPage: Int = 0
  private(set) var hasMoreData: Bool = true
  let pageSize: Int

  init(pageSize: Int = 10) {
    self.pageSize = pageSize
  }

  /// 다음 페이지로 이동
  func moveToNextPage() {
    currentPage += 1
  }

  /// 받은 데이터 개수를 기반으로 더 이상 데이터가 있는지 확인
  func updateHasMoreData(receivedCount: Int) {
    hasMoreData = receivedCount >= pageSize
  }

  /// 페이지네이션 상태 초기화 (새로고침 시 사용)
  func reset() {
    currentPage = 0
    hasMoreData = true
  }

  /// 첫 페이지인지 확인
  var isFirstPage: Bool {
    currentPage == 0
  }
}
