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
        case .invalidURL: return "잘못된 URL"
        case .http(let s, _): return "서버 오류(\(s))"
        case .decoding(let e): return "디코딩 오류: \(e.localizedDescription)"
        case .underlying(let e): return e.localizedDescription
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
        self.session = URLSession(configuration: cfg)
    }

    func postJSON<Request: Encodable, Response: Decodable>(
        path: String,
        body: Request
    ) async throws -> Response {
        guard let url = URL(string: path, relativeTo: baseURL) else { throw APIError.invalidURL }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.httpBody = try JSONEncoder().encode(body)

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIError.underlying(URLError(.badServerResponse)) }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.http(status: http.statusCode, data: data)
        }
        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            // 성공 스펙이 래핑되어 있지 않거나 빈 바디일 수 있으니 필요시 분기
            throw APIError.decoding(error)
        }
    }
}
