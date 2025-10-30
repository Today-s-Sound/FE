//
//  SessionStore.swift
//  today-s-sound
//
//  Created by 하승연 on 10/30/25.
//

import Foundation
import SwiftUI

@MainActor
final class SessionStore: ObservableObject {
    @Published private(set) var userId: String?
    @Published private(set) var isRegistered: Bool = false
    @Published var lastError: String?

    private let api = APIClient()

    init() {
        // 앱 시작 시, 키체인에 저장되어 있으면 로드
        if let savedId = Keychain.getString(for: KeychainKey.userId) {
            self.userId = savedId
            self.isRegistered = true
        } else {
            self.isRegistered = false
        }
    }

    /// 처음 실행 시 한 번 호출: deviceSecret 생성/보관 → 서버 등록
    func registerIfNeeded() async {
        guard !isRegistered else { return }

        // 1) deviceSecret을 키체인에서 찾고, 없으면 생성하여 저장
        let secret: String = {
            if let s = Keychain.getString(for: KeychainKey.deviceSecret) { return s }
            let gen = DeviceSecret.generate()
            Keychain.setString(gen, for: KeychainKey.deviceSecret)
            return gen
        }()

        do {
            // 2) 서버 호출
            let body = RegisterAnonymousBody(deviceSecret: secret)
            typealias Resp = SuccessEnvelope<AnonymousResult>
            let envelope: Resp = try await api.postJSON(path: "/api/users/anonymous", body: body)

            // 3) user_id 보관
            Keychain.setString(envelope.result.user_id, for: KeychainKey.userId)
            self.userId = envelope.result.user_id
            self.isRegistered = true

            // (옵션) 서버가 api_key 같은 걸 준다면 저장
            // if let key = envelope.result.api_key { Keychain.setString(key, for: KeychainKey.apiKey) }

        } catch let APIError.http(_, data) {
            // 스웨거 에러 포맷 시도 디코딩
            if let data, let err = try? JSONDecoder().decode(ErrorEnvelope.self, from: data) {
                lastError = "[\(err.code)] \(err.message)"
            } else {
                lastError = "알 수 없는 서버 오류"
            }
        } catch {
            lastError = error.localizedDescription
        }
    }
}
