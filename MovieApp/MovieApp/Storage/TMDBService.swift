//
//  TMDBService.swift
//  MovieApp
//
//  Created by 이정인 on 3/3/26.
//

import Foundation

// MARK: - TMDB 설정
final class TMDBService {

    private let apiKey = "86a96ecf8ea21bb7970cff00d5eedf79" // 내 API 키

    private let baseURL = "https://api.themoviedb.org/3"
    private let imageBaseURL = "https://image.tmdb.org/t/p/w500"
    private let language = "ko-KR"
    private let region = "KR"

    // MARK: - TMDB API
    
    // "무비 차트" API
    func fetchPopular(completion: @escaping (Result<[Movie], Error>) -> Void) {
        request(path: "/movie/popular", completion: completion)
    }
    
    // "현재 상영작" API
    func fetchNowPlaying(completion: @escaping (Result<[Movie], Error>) -> Void) {
        request(path: "/movie/now_playing", completion: completion)
    }
    
    // "상영 예정" API
    func fetchUpcoming(completion: @escaping (Result<[Movie], Error>) -> Void) {
        request(path: "/movie/upcoming", completion: completion)
    }

    // "전체 영화" API
    func fetchDiscover(page: Int = 1, completion: @escaping (Result<[Movie], Error>) -> Void) {
        request(
            path: "/discover/movie",
            extraQueryItems: [
                URLQueryItem(name: "sort_by", value: "popularity.desc"),
                URLQueryItem(name: "include_adult", value: "false"),
                URLQueryItem(name: "include_video", value: "false"),
                URLQueryItem(name: "page", value: "\(page)")
            ],
            completion: completion
        )
    }
    
    // "검색" API
    func searchMovies(query: String, page: Int = 1, completion: @escaping (Result<[Movie], Error>) -> Void) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            completion(.success([]))
            return
        }

        request(
            path: "/search/movie",
            extraQueryItems: [
                URLQueryItem(name: "include_adult", value: "false"),
                URLQueryItem(name: "query", value: trimmed),
                URLQueryItem(name: "page", value: "\(page)") 
            ],
            completion: completion
        )
    }

    // MARK: - API 요청
    private func request(
        path: String,
        extraQueryItems: [URLQueryItem] = [],
        completion: @escaping (Result<[Movie], Error>) -> Void
    ) {

        guard var components = URLComponents(string: baseURL + path) else {
            completion(.failure(TMDBError.invalidURL))
            return
        }

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "language", value: language),
            URLQueryItem(name: "region", value: region)
        ]

        queryItems.append(contentsOf: extraQueryItems)
        components.queryItems = queryItems

        guard let url = components.url else {
            completion(.failure(TMDBError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(.failure(TMDBError.invalidResponse)) }
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async { completion(.failure(TMDBError.httpStatus(httpResponse.statusCode))) }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(TMDBError.invalidResponse)) }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(MovieResponse.self, from: data)
                DispatchQueue.main.async { completion(.success(decoded.results)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(TMDBError.decoding)) }
            }

        }.resume()
    }

    // MARK: - 영화 포스터 이미지 URL 도우미
    func makePosterURL(path: String) -> URL? {
        URL(string: imageBaseURL + path)
    }
}
