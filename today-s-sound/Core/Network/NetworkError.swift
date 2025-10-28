import Foundation

enum NetworkError: Error {
  case invalidURL
  case requestFailed(Error)
  case decodingFailed(Error)
  case serverError(statusCode: Int)
  case unknown
}
