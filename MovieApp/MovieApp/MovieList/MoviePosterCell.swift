//
//  MoviePosterCell.swift
//  MovieApp
//
//  Created by 이정인 on 3/3/26.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class MoviePosterCell: UICollectionViewCell {
    static let id = "MoviePosterCell"

    // MARK: TMDBConfig 없이 여기서 바로 사용
    private static let imageBaseURL = "https://image.tmdb.org/t/p/w500"

    private let posterImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
        $0.backgroundColor = .systemGray5
    }

    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .semibold)
        $0.textColor = .label
        $0.numberOfLines = 2
    }

    private let favoriteBadge = UIImageView().then {
        $0.image = UIImage(systemName: "heart.fill")
        $0.tintColor = .systemPink
        $0.isHidden = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.kf.cancelDownloadTask()
        posterImageView.image = nil
        posterImageView.contentMode = .scaleAspectFill
        titleLabel.text = nil
        favoriteBadge.isHidden = true
    }

    private func configureUI() {
        
        [posterImageView, titleLabel, favoriteBadge].forEach { contentView.addSubview($0) }

        posterImageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(210)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(posterImageView.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(2)
            $0.bottom.lessThanOrEqualToSuperview()
        }

        favoriteBadge.snp.makeConstraints {
            $0.top.equalTo(posterImageView.snp.top).offset(8)
            $0.trailing.equalTo(posterImageView.snp.trailing).inset(8)
            $0.width.height.equalTo(18)
        }
    }

    func configure(movie: Movie, isFavorite: Bool) {
        titleLabel.text = movie.title
        favoriteBadge.isHidden = !isFavorite

        if let path = movie.posterPath,
           let url = URL(string: Self.imageBaseURL + path) {

            posterImageView.contentMode = .scaleAspectFill
            posterImageView.kf.setImage(
                with: url,
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            )
        } else {
            posterImageView.image = UIImage(systemName: "film")
            posterImageView.contentMode = .center
        }
    }
}
