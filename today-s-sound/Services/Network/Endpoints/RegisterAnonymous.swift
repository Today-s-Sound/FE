//
//  RegisterAnonymous.swift
//  today-s-sound
//
//  Created by 하승연 on 10/30/25.
//

import Foundation
import CryptoKit

// 1) Request
struct RegisterAnonymousBody: Encodable {
    let deviceSecret: String
}

// 2) 성공 Response 래퍼
struct SuccessEnvelope<Result: Decodable>: Decodable {
    let errorCode: String?
    let message: String
    let result: Result
}

struct AnonymousResult: Decodable {
    let user_id: String
    // 서버가 추가로 키 같은 걸 준다면 여기에 옵셔널로:
    // let api_key: String?
}

// 3) 에러 Response
struct ErrorEnvelope: Decodable, Error {
    let status: Int
    let code: String
    let message: String
}

// 4) deviceSecret 생성 유틸 (32바이트 랜덤 → base64URL)
enum DeviceSecret {
    static func generate() -> String {
        var bytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        // URL-safe base64
        let data = Data(bytes)
        return data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
