//
//  ErrorResponse.swift
//  NShopping
//
//  Created by ilim on 2025-02-26.
//

import Foundation

struct ErrorResponse: Codable {
    let errorMessage: String
    let errorCode: String
}

enum NetworkError: Error {
    case invalidResponse
    case apiError(String)
    case statusCodeError(Int, String)
    case unknown(Error)

    var description: String {
        switch self {
        case .invalidResponse:
            return "유효하지 않은 응답입니다."
        case .apiError(let message):
            return message
        case .statusCodeError(let code, let message):
            return "오류 \(code): \(message)"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
