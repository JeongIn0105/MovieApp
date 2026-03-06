//
//  MyPageTableViewCell.swift
//  MovieApp
//

import UIKit
import SnapKit
import Then

final class MyPageTableViewCell: UITableViewCell {

    static let identifier = "MyPageTableViewCell"
    var onCancelTapped: (() -> Void)?

    // MARK: - UI
    private let posterView = UIImageView().then {
        $0.backgroundColor = .systemGray5
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.systemGray4.cgColor
    }
    private let placeholderLabel = UILabel().then {
        $0.text = "이미지"; $0.textColor = .systemCyan; $0.font = .systemFont(ofSize: 12)
    }
    private let infoLabel = UILabel().then {
        $0.numberOfLines = 0; $0.font = .systemFont(ofSize: 14, weight: .medium)
    }
    private let cancelButton = UIButton(type: .system).then {
        $0.setTitle("예매 취소", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        $0.backgroundColor = UIColor(red:0.93,green:0.11,blue:0.14,alpha:1)
        $0.layer.cornerRadius = 6
    }
    // 취소된 항목 뱃지
    private let cancelledBadge = UILabel().then {
        $0.text = "취소됨"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 11, weight: .bold)
        $0.backgroundColor = .systemGray2
        $0.textAlignment = .center
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
        $0.isHidden = true
    }

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterView.image = nil
        infoLabel.text = nil
        onCancelTapped = nil
        cancelButton.isHidden = false
        cancelledBadge.isHidden = true
    }

    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle  = .none
        [posterView, infoLabel, cancelButton, cancelledBadge].forEach { contentView.addSubview($0) }
        posterView.addSubview(placeholderLabel)

        posterView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(15)
            $0.width.equalTo(70); $0.height.equalTo(100)
            $0.bottom.lessThanOrEqualToSuperview().offset(-15)
        }
        placeholderLabel.snp.makeConstraints { $0.center.equalToSuperview() }
        infoLabel.snp.makeConstraints {
            $0.leading.equalTo(posterView.snp.trailing).offset(15)
            $0.top.equalTo(posterView)
            $0.trailing.equalToSuperview().offset(-20)
        }
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(8)
            $0.leading.equalTo(infoLabel.snp.leading)
            $0.width.equalTo(80); $0.height.equalTo(28)
            $0.bottom.lessThanOrEqualToSuperview().offset(-15)
        }
        cancelledBadge.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(8)
            $0.leading.equalTo(infoLabel.snp.leading)
            $0.width.equalTo(60); $0.height.equalTo(22)
            $0.bottom.lessThanOrEqualToSuperview().offset(-15)
        }

        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }

    @objc private func cancelTapped() { onCancelTapped?() }

    // MARK: - Configure
    func configure(with r: SavedReservation, isCancelled: Bool) {
        // 포스터
        if let data = r.posterData, let img = UIImage(data: data) {
            posterView.image = img
            placeholderLabel.isHidden = true
        } else {
            posterView.image = nil
            placeholderLabel.isHidden = false
        }

        // 정보
        let fmt = NumberFormatter(); fmt.numberStyle = .decimal
        let priceStr = fmt.string(from: NSNumber(value: r.totalPrice)) ?? "\(r.totalPrice)"
        infoLabel.text = "\(r.movieTitle)\n\(r.date)  \(r.time)\n\(r.ticketTypes)\n\(priceStr)원"

        // 취소 여부에 따라 버튼/뱃지 전환
        cancelButton.isHidden = isCancelled
        cancelledBadge.isHidden = !isCancelled
    }
}
