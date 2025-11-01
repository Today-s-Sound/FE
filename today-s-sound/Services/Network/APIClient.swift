//
//  APIClient.swift
//  today-s-sound
//
//  Created by 하승연 on 10/30/25.
//

import Foundation

enum APIError: Error, LocalizedError {
  case invalidURL
  case http(status: Int, data: Data?)
  case decoding(Error)
  case underlying(Error)

  var errorDescription: String? {
    switch self {
    case .invalidURL: "잘못된 URL"
    case let .http(s, _): "서버 오류(\(s))"
    case let .decoding(e): "디코딩 오류: \(e.localizedDescription)"
    case let .underlying(e): e.localizedDescription
    }
  }
}

final class APIClient {
  private let baseURL: URL
  private let session: URLSession

  init(baseURL: URL = AppConfig.baseURL) {
    self.baseURL = baseURL
    let cfg = URLSessionConfiguration.default
    cfg.httpCookieStorage = HTTPCookieStorage.shared
    cfg.httpShouldSetCookies = true
    cfg.httpAdditionalHeaders = ["Accept": "application/json",
                                 "Content-Type": "application/json"]
    session = URLSession(configuration: cfg)
  }

  func postJSON<Response: Decodable>(
    path: String,
    body: some Encodable,
    headers: [String: String] = [:] // ← 추가: 요청별 헤더
  ) async throws -> Response {
    guard let url = URL(string: path, relativeTo: baseURL) else { throw APIError.invalidURL }
    var req = URLRequest(url: url)
    req.httpMethod = "POST"
    req.httpBody = try JSONEncoder().encode(body)

    // 공통 헤더는 configuration.httpAdditionalHeaders에서 이미 세팅됨
    // 요청별 헤더 합치기
    for (key, value) in headers {
      req.setValue(value, forHTTPHeaderField: key)
    }

    let (data, resp) = try await session.data(for: req)
    guard let http = resp as? HTTPURLResponse else { throw APIError.underlying(URLError(.badServerResponse)) }
    guard (200 ..< 300).contains(http.statusCode) else {
      throw APIError.http(status: http.statusCode, data: data)
    }
    do {
      return try JSONDecoder().decode(Response.self, from: data)
    } catch {
      throw APIError.decoding(error)
    }
  }
}
