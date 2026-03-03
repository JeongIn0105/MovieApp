//
//  MovieData.swift
//  MovieApp
//
//  Created by 이정인 on 3/3/26.
//

import Foundation

// MARK: - 영화 데이터
struct MovieResponse: Decodable {
    let results: [Movie]
}

struct Movie: Decodable {
    let id: Int
    let title: String
    let overview: String?
    let posterPath: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
    }
}
