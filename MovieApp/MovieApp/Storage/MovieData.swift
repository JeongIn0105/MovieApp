//
//  MovieData.swift
//  MovieApp
//
//  Created by 이정인 on 3/3/26.
//

import Foundation

// MARK: - 영화 리스트 응답
struct MovieResponse: Decodable {
    let results: [Movie]
}

// MARK: - 영화 모델
struct Movie: Decodable {

    // MARK: 기본 정보
    let id: Int
    let title: String
    let overview: String?
    let posterPath: String?

    // MARK: 영화 목록 / 영화 검색 API 데이터
    let releaseDate: String?
    let genreIds: [Int]?
    let voteAverage: Double?
    let voteCount: Int?
    let popularity: Double?

    // MARK: 영화 상세 API 데이터 (/movie/{id})
    let runtime: Int?
    let genres: [Genre]?
    let adult: Bool?

    struct Genre: Decodable {
        let id: Int
        let name: String
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview

        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case genreIds = "genre_ids"

        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case popularity

        case runtime
        case genres
        case adult
    }
}

// MARK: - /movie/{id}/release_dates (나이 등급)
struct MovieReleaseDatesResponse: Decodable {
    let results: [MovieReleaseDatesCountry]

    func certification(for countryCode: String) -> String? {
        guard let country = results.first(where: { $0.iso3166_1.uppercased() == countryCode.uppercased() }) else {
            return nil
        }

        // certification이 빈 문자열인 경우가 많아서, 비어있지 않은 첫 값 찾기
        let cert = country.releaseDates
            .map { $0.certification.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first(where: { !$0.isEmpty })

        return normalizeCertification(cert)
    }

    private func normalizeCertification(_ raw: String?) -> String? {
        guard let raw, !raw.isEmpty else { return nil }

        // 나이 배지 ALL/12/15/19 형태
        if raw == "0" { return "ALL" }
        if raw == "18" { return "19" } // 한국은 보통 19세 이상으로 표기
        return raw
    }
}

struct MovieReleaseDatesCountry: Decodable {
    let iso3166_1: String
    let releaseDates: [MovieReleaseDateItem]

    enum CodingKeys: String, CodingKey {
        case iso3166_1 = "iso_3166_1"
        case releaseDates = "release_dates"
    }
}

struct MovieReleaseDateItem: Decodable {
    let certification: String
}
