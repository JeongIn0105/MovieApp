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

    // MARK: - API 요청
    private func request(path: String,
                         completion: @escaping (Result<[Movie], Error>) -> Void) {

        guard var components = URLComponents(string: baseURL + path) else {
            completion(.failure(TMDBError.invalidURL))
            return
        }

        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey), // API 키
            URLQueryItem(name: "language", value: language), // 언어
            URLQueryItem(name: "region", value: region) // 지역
        ]

        guard let url = components.url else {
            completion(.failure(TMDBError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(TMDBError.invalidResponse))
                }
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(TMDBError.httpStatus(httpResponse.statusCode)))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(TMDBError.invalidResponse))
                }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(MovieResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decoded.results))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(TMDBError.decoding))
                }
            }

        }.resume()
    }

    // MARK: - 영화 포스터 이미지 URL 도우미
    func makePosterURL(path: String) -> URL? {
        return URL(string: imageBaseURL + path)
    }
}
