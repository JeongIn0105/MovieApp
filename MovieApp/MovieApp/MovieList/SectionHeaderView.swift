//
//  SectionHeaderView.swift
//  MovieApp
//
//  Created by 이정인 on 3/3/26.
//

import UIKit
import SnapKit
import Then

final class SectionHeaderView: UICollectionReusableView {
    static let reuseId = "SectionHeaderView"

    private let titleLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 26)
        $0.textColor = .label
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String) {
        titleLabel.text = title
    }
}
