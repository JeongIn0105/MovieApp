//
//  ReservationStore.swift
//  MovieApp
//
//  예매 데이터를 UserDefaults에 저장/불러오기/취소하는 싱글톤 저장소

import Foundation

// MARK: - 저장 가능한 예매 모델 (Codable)
struct SavedReservation: Codable, Equatable {
    let id: String            // UUID
    let movieTitle: String
    let posterData: Data?     // 포스터 이미지 (PNG)
    let date: String          // "2026.03.05"
    let time: String          // "09:00 ~ 11:00"
    let seatLocation: String  // "A3, A4"
    let headCount: Int
    let ticketTypes: String   // "일반 2, 청소년 1"
    let totalPrice: Int
    var isCancelled: Bool
}

// MARK: - ReservationStore
final class ReservationStore {
    static let shared = ReservationStore()
    private init() {}

    private let key = "saved_reservations"

    // 전체 불러오기
    func loadAll() -> [SavedReservation] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let list = try? JSONDecoder().decode([SavedReservation].self, from: data)
        else { return [] }
        return list
    }

    // 결제 완료 목록
    func loadCompleted() -> [SavedReservation] {
        loadAll().filter { !$0.isCancelled }
    }

    // 결제 취소 목록
    func loadCancelled() -> [SavedReservation] {
        loadAll().filter { $0.isCancelled }
    }

    // 저장
    func save(_ reservation: SavedReservation) {
        var list = loadAll()
        list.insert(reservation, at: 0)
        if let data = try? JSONEncoder().encode(list) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    // 취소 처리
    func cancel(id: String) {
        var list = loadAll()
        guard let idx = list.firstIndex(where: { $0.id == id }) else { return }
        list[idx].isCancelled = true
        if let data = try? JSONEncoder().encode(list) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
