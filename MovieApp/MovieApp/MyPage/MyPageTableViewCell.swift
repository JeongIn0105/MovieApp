//
//  MyPageTableViewCell.swift
//  MovieApp
//
//  Created by t2025-m0239 on 2026.03.05.
//

import UIKit
import SnapKit
import Then

final class MyPageTableViewCell: UITableViewCell {

    static let identifier = "MyPageTableViewCell"

        // MARK: - UI Components
    private let moviePosterView = UIImageView().then {
        $0.backgroundColor = .white
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.systemGray4.cgColor
    }

    private let placeholderLabel = UILabel().then {
        $0.text = "이미지"
        $0.textColor = .systemCyan
        $0.font = .systemFont(ofSize: 14)
    }

    private let infoLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.textColor = .red
        $0.font = .systemFont(ofSize: 15, weight: .medium)
    }

        // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        self.backgroundColor = .clear
        self.selectionStyle = .none

        [moviePosterView, infoLabel].forEach { contentView.addSubview($0) }
        moviePosterView.addSubview(placeholderLabel)

        moviePosterView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(15)
            $0.width.equalTo(70)
            $0.height.equalTo(90)
            $0.bottom.equalToSuperview().offset(-15)
        }

        placeholderLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        infoLabel.snp.makeConstraints {
            $0.leading.equalTo(moviePosterView.snp.trailing).offset(15)
            $0.top.equalTo(moviePosterView.snp.top)
            $0.trailing.equalToSuperview().offset(-20)
        }
    }

        // MARK: - Data Binding
    func configure(with model: ReservationData) {
        infoLabel.text = "\(model.movieName)\n\(model.dateTime)\n일반 1\n\(model.price)"
    }
}
