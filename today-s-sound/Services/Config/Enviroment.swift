//
//  Enviroment.swift
//  today-s-sound
//
//  Created by 하승연 on 10/30/25.
//

import Foundation

enum AppConfig {
    // 배포/개발 분기 필요하면 Scheme/xcconfig로 주입해도 됨
    static let baseURL = URL(string: "http://localhost:8080")! // 예: https://api.example.com
}
