//
//  TMDBError.swift
//  MovieApp
//
//  Created by 이정인 on 3/3/26.
//

import Foundation

// MARK: - 네트워크 에러 처리
enum TMDBError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case decoding

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL이 올바르지 않습니다."
        case .invalidResponse:
            return "응답이 올바르지 않습니다."
        case .httpStatus(let code):
            return "서버 오류 (status: \(code))"
        case .decoding:
            return "데이터 파싱에 실패했습니다."
        }
    }
}
