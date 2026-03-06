//
//  BookingModel.swift
//  MovieApp
//
//  Created by t2025-m0239 on 2026.03.05.
//

import Foundation

struct BookingModel {
    let movieTitle: String
    let date: String
    let seatLocation: String
    let headCount: Int
    let totalPrice: Int

        // 가격 포맷팅 (예: 20,000 원)
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let priceString = formatter.string(from: NSNumber(value: totalPrice)) ?? "\(totalPrice)"
        return "\(priceString) 원"
    }
}
