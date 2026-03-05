//
//  TMDBService.swift
//  MovieApp
//
//  Created by 이정인 on 3/3/26.
//

import Foundation

// MARK: - TMDB 설정
final class TMDBService {

    // MARK: Config
    private let apiKey = "86a96ecf8ea21bb7970cff00d5eedf79"
    private let baseURL = "https://api.themoviedb.org/3"
    private let imageBaseURL = "https://image.tmdb.org/t/p/w500"
    private let language = "ko-KR"
    private let region = "KR"          // 목록용 region
    private let certificationCountry = "KR" // 나이 등급은 국가 코드로 조회

    // MARK: - 영화 API (영화 목록 페이지)
    func fetchPopular(completion: @escaping (Result<[Movie], Error>) -> Void) {
        requestList(path: "/movie/popular", completion: completion)
    }

    func fetchNowPlaying(completion: @escaping (Result<[Movie], Error>) -> Void) {
        requestList(path: "/movie/now_playing", completion: completion)
    }

    func fetchUpcoming(completion: @escaping (Result<[Movie], Error>) -> Void) {
        requestList(path: "/movie/upcoming", completion: completion)
    }

    func fetchDiscover(page: Int = 1, completion: @escaping (Result<[Movie], Error>) -> Void) {
        requestList(
            path: "/discover/movie",
            extraQueryItems: [
                .init(name: "sort_by", value: "popularity.desc"),
                .init(name: "include_adult", value: "false"),
                .init(name: "include_video", value: "false"),
                .init(name: "page", value: "\(page)")
            ],
            completion: completion
        )
    }

    // MARK: - 영화 API (영화 검색 페이지)
    func searchMovies(query: String, page: Int = 1, completion: @escaping (Result<[Movie], Error>) -> Void) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            completion(.success([]))
            return
        }

        requestList(
            path: "/search/movie",
            extraQueryItems: [
                .init(name: "include_adult", value: "false"),
                .init(name: "query", value: trimmed),
                .init(name: "page", value: "\(page)")
            ],
            completion: completion
        )
    }

    // MARK: - 영화 API (영화 세부 페이지)
    func fetchMovieDetail(id: Int, completion: @escaping (Result<Movie, Error>) -> Void) {
        requestDecodable(path: "/movie/\(id)", completion: completion)
    }

    // MARK: - 영화 나이 등급(ALL/12/15/19) 가져오기
    // TMDB: /movie/{movie_id}/release_dates
    func fetchMovieCertification(movieId: Int, completion: @escaping (Result<String, Error>) -> Void) {
        requestDecodable(path: "/movie/\(movieId)/release_dates") { (result: Result<MovieReleaseDatesResponse, Error>) in
            switch result {
            case .success(let response):
                let cert = response.certification(for: self.certificationCountry)
                completion(.success(cert ?? "ALL"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - 영화 포스터 URL 
    func makePosterURL(path: String) -> URL? {
        URL(string: imageBaseURL + path)
    }
}

// MARK: - 네트워크
private extension TMDBService {

    func requestDecodable<T: Decodable>(
        path: String,
        extraQueryItems: [URLQueryItem] = [],
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = makeURL(path: path, extraQueryItems: extraQueryItems) else {
            completion(.failure(TMDBError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
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

            guard let data else {
                DispatchQueue.main.async { completion(.failure(TMDBError.invalidResponse)) }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async { completion(.success(decoded)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(TMDBError.decoding)) }
            }
        }.resume()
    }

    func requestList(
        path: String,
        extraQueryItems: [URLQueryItem] = [],
        completion: @escaping (Result<[Movie], Error>) -> Void
    ) {
        requestDecodable(path: path, extraQueryItems: extraQueryItems) { (result: Result<MovieResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func makeURL(path: String, extraQueryItems: [URLQueryItem]) -> URL? {
        guard var components = URLComponents(string: baseURL + path) else { return nil }

        var queryItems: [URLQueryItem] = [
            .init(name: "api_key", value: apiKey),
            .init(name: "language", value: language),
            .init(name: "region", value: region)
        ]
        queryItems.append(contentsOf: extraQueryItems)
        components.queryItems = queryItems

        return components.url
    }
}

