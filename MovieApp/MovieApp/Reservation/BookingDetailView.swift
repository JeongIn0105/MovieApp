//
//  BookingDetailView.swift
//  MovieApp
//
//  Created by t2025-m0239 on 2026.03.05.
//

import UIKit
import SnapKit
import Then

class BookingDetailView: UIView {

        // MARK: - UI Components
    let posterImageView = UIImageView().then {
        $0.backgroundColor = .systemGray5
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }

    let infoStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 20
        $0.distribution = .fillEqually
    }

    let paymentButton = UIButton().then {
        $0.setTitle("결제하기", for: .normal)
        $0.backgroundColor = .red
        $0.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .white
        [posterImageView, infoStackView, paymentButton].forEach { addSubview($0) }

        posterImageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(snp.width).multipliedBy(1.1)
        }

        infoStackView.snp.makeConstraints {
            $0.top.equalTo(posterImageView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        paymentButton.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(80)
        }
    }

        // 데이터를 받아 UI를 업데이트하는 메서드
    func configure(with model: BookingModel) {
        infoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let rows = [
            ("영화", model.movieTitle),
            ("날짜", model.date),
            ("좌석 위치", model.seatLocation),
            ("인원", "\(model.headCount)"),
            ("", ""), // 간격용 스페이서 역할
            ("총 가격", model.formattedPrice)
        ]

        rows.forEach { title, content in
            if title.isEmpty {
                infoStackView.addArrangedSubview(UIView())
            } else {
                infoStackView.addArrangedSubview(createInfoRow(title: title, content: content))
            }
        }
    }

    private func createInfoRow(title: String, content: String) -> UIView {
        let container = UIView()
        let tLabel = UILabel().then { $0.text = title; $0.font = .systemFont(ofSize: 18, weight: .bold) }
        let cLabel = UILabel().then { $0.text = content; $0.font = .systemFont(ofSize: 18, weight: .bold); $0.textAlignment = .right }

        container.addSubview(tLabel)
        container.addSubview(cLabel)

        tLabel.snp.makeConstraints { $0.leading.centerY.equalToSuperview() }
        cLabel.snp.makeConstraints { $0.trailing.centerY.equalToSuperview() }

        return container
    }
}
