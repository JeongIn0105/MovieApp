//
//  MovieDetailVIewController.swift
//  MovieApp
//
//  Created by 이정인 on 3/4/26.
//

/*
 - 영화를 클릭시 영화의 세부 페이지로 이동해주세요
 - 영화의 정보를 함께 페이지에 보여주세요
 */

// MARK: - 영화 세부 페이지 구현
import UIKit
import SnapKit
import Then

final class MovieDetailViewController: UIViewController {
    
    private let movie: Movie
    private let service = TMDBService()
    
    // MARK: - UIKit 설정
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
    }
    
    private let contentView = UIView()
    
    // MARK: 영화 포스터
    private let posterImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .darkGray
    }
    
    // 포스터 이미지 위에 어둡게 덮는 반투명 뷰
    private let posterDimView = UIView().then {
        $0.backgroundColor = .clear
        $0.isUserInteractionEnabled = false
    }
    
    // MARK: - 영화 제목, 나이 배지
    private let titleRow = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 10
    }
    
    private let titleContainer = UIView()
    
    private let titleLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .boldSystemFont(ofSize: 30)
        $0.numberOfLines = 2
        $0.lineBreakMode = .byWordWrapping
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    private let ageBadgeLabel = PaddingLabel().then {
        $0.text = "ALL"
        $0.font = .boldSystemFont(ofSize: 14)
        $0.textAlignment = .center
        $0.textInsets = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        $0.layer.cornerRadius = 6
        $0.clipsToBounds = true
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private let metaLabel = UILabel().then {
        $0.textColor = .white.withAlphaComponent(0.85)
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.numberOfLines = 2
        $0.lineBreakMode = .byWordWrapping
    }
    
    // MARK: - 통계(예매율 / 누적관객수 / 에그지수)
    private let statsStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .top
        $0.spacing = 14
    }
    
    private let bookingStat = StatPillView(iconSystemName: "ticket.fill", title: "예매율")
    private let audienceStat = StatPillView(iconSystemName: "person.2.fill", title: "누적관객수")
    private let eggStat = StatPillView(iconSystemName: "flame.fill", title: "에그지수")
    
    // MARK: - 프롤로그
    private let prologueTitleLabel = UILabel().then {
        $0.text = "프롤로그"
        $0.textColor = .white
        $0.font = .boldSystemFont(ofSize: 22)
    }
    
    private let prologueBox = UIView().then {
        $0.backgroundColor = UIColor(white: 0.12, alpha: 1.0)
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
    }
    
    private let prologueLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 15, weight: .medium)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    // MARK: - 예매하기 버튼
    private let bookButton = UIButton().then {
        $0.setTitle("예매하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 24)
        $0.backgroundColor = UIColor(red: 235/255, green: 6/255, blue: 6/255, alpha: 1.0)
    }
    
    // MARK: - Init
    init(movie: Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - LifeCycle(생명주기)
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        configureUI()
        addPosterGradient()
        
        bindBaseMovie()
        loadPosterImage()
        
        fetchDetail()
        fetchCertification()
    }
    
    // MARK: - 전체 레이아웃 설정
    private func configureUI() {
        view.addSubview(scrollView)
        view.addSubview(bookButton)
        
        scrollView.addSubview(contentView)
        
        bookButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(70)
            $0.width.equalTo(view)
            $0.height.equalTo(60)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bookButton.snp.top)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        // Add subviews
        [posterImageView, posterDimView, titleRow, metaLabel, statsStackView, prologueTitleLabel, prologueBox]
            .forEach { contentView.addSubview($0) }
        
        prologueBox.addSubview(prologueLabel)
        
        // Title Row 구성
        titleRow.addArrangedSubview(titleContainer)
        titleContainer.addSubview(titleLabel)
        titleRow.addArrangedSubview(ageBadgeLabel)
        
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // 통계
        [bookingStat, audienceStat, eggStat].forEach { statsStackView.addArrangedSubview($0) }
        
        // 레이아웃 제약 조건
        posterImageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(520)
        }
        
        posterDimView.snp.makeConstraints {
            $0.edges.equalTo(posterImageView)
        }
        
        titleRow.snp.makeConstraints {
            $0.top.equalTo(posterImageView.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        ageBadgeLabel.snp.makeConstraints {
            $0.height.equalTo(30)
            $0.leading.equalTo(titleLabel.snp.trailing).inset(10)
        }
        
        metaLabel.snp.makeConstraints {
            $0.top.equalTo(titleRow.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        statsStackView.snp.makeConstraints {
            $0.top.equalTo(metaLabel.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.greaterThanOrEqualTo(110)
        }
        
        prologueTitleLabel.snp.makeConstraints {
            $0.top.equalTo(statsStackView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        prologueBox.snp.makeConstraints {
            $0.top.equalTo(prologueTitleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(24 + 80) 
        }
        
        prologueLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
    }
    
    // 포스터 위에 위·중간·아래가 다른 투명도의 검정 그라데이션 레이어를 추가하는 메서드.
    private func addPosterGradient() {
        
        // 그라데이션 레이어 생성
        let gradient = CAGradientLayer()
        
        // 그라데이션 색상 설정
        gradient.colors = [
            UIColor(white: 0.0, alpha: 0.65).cgColor,
            UIColor(white: 0.0, alpha: 0.10).cgColor,
            UIColor(white: 0.0, alpha: 0.85).cgColor
        ]
        
        // 색상 위치 설정
        gradient.locations = [0.0, 0.55, 1.0]
        
        // 그라데이션 크기 설정
        gradient.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 520)
        
        // 기존 그라데이션 제거
        posterDimView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        // 그라데이션 추가
        posterDimView.layer.insertSublayer(gradient, at: 0)
    }
    
    // MARK: - 영화 상세 페이지가 처음 열릴 때, 리스트에서 받은 기본 영화 데이터를 UI에 먼저 표시
    private func bindBaseMovie() {
        
        // 영화 제목 표시
        titleLabel.text = movie.title
        
        // 개봉일 + 장르 표시
        let release = movie.releaseDate ?? "개봉일 정보 없음"
        let genre = genreText(from: movie.genreIds)
        metaLabel.text = "\(release) 개봉  ·  시간 정보 없음  ·  \(genre)"
        
        // 영화 설명 표시
        let ov = (movie.overview ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        prologueLabel.text = ov.isEmpty ? "영화 설명이 없습니다" : ov
        
        // 나이 배지 초기 설정
        applyAgeBadge("ALL")
        
        // 통계 초기 표시
        applyStats(popularity: movie.popularity, voteCount: movie.voteCount, voteAverage: movie.voteAverage)
    }
    
    // MARK: - 영화 상세 API
    private func fetchDetail() {
        service.fetchMovieDetail(id: movie.id) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let detail):
                let runtimeText: String = {
                    guard let rt = detail.runtime else { return "시간 정보 없음" }
                    return "\(rt / 60)시간 \(rt % 60)분"
                }()
                
                let genreText = detail.genres?.prefix(3).map(\.name).joined(separator: ", ")
                ?? self.genreText(from: self.movie.genreIds)
                
                let release = detail.releaseDate ?? self.movie.releaseDate ?? "개봉일 정보 없음"
                self.metaLabel.text = "\(release) 개봉  ·  \(runtimeText)  ·  \(genreText)"
                
                let overview = (detail.overview ?? self.movie.overview ?? "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                self.prologueLabel.text = overview.isEmpty ? "영화 설명이 없습니다" : overview
                
                self.applyStats(
                    popularity: detail.popularity,
                    voteCount: detail.voteCount,
                    voteAverage: detail.voteAverage
                )
                
            case .failure(let error):
                print("fetchMovieDetail error:", error)
            }
        }
    }
    
    // MARK: - TMDB API에서 영화 관람등급(ALL / 12 / 15 / 19)을 가져와서 나이 배지를 설정
    private func fetchCertification() {
        service.fetchMovieCertification(movieId: movie.id) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let cert):
                self.applyAgeBadge(cert)
            case .failure(let error):
                print("fetchMovieCertification error:", error)
                self.applyAgeBadge("ALL")
            }
        }
    }
    
    // MARK: - 영화 포스터 API 불러오기
    private func loadPosterImage() {
        guard let path = movie.posterPath,
              let url = URL(string: "https://image.tmdb.org/t/p/w500\(path)") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self, let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async { self.posterImageView.image = image }
        }.resume()
    }
    
    // MARK: - 예매율 / 누적관객수 / 에그지수 퍼센트 표시
    private func applyStats(popularity: Double?, voteCount: Int?, voteAverage: Double?) {
        
        // 1) 예매율 : popularity를 0~100으로 완만하게 변환
        let pop = max(0, popularity ?? 0)
        // 보통 popularity가 0~200+ 까지 나올 수 있어서 스케일링
        let booking = Int(min(99, max(1, (pop / 2.5).rounded()))) // 0~250 -> 0~100 느낌
        bookingStat.setValue("\(booking)%")
        
        // 2) 누적관객수 : voteCount를 완만한 "만" 단위로
        let votes = max(0, voteCount ?? 0)
        // votes가 너무 작으면 1만, 커지면 서서히 증가
        let man = min(999, max(1, Int((Double(votes).squareRoot() * 2).rounded())))
        audienceStat.setValue("\(man)만")
        
        // 3) 에그지수(표시용): voteAverage 우선, 없으면 popularity로 보정
        if let avg = voteAverage, avg > 0 {
            let egg = max(0, min(100, Int((avg * 10).rounded())))
            eggStat.setValue("\(egg)%")
        } else {
            let egg = max(0, min(100, Int(min(100, (pop / 2.0)).rounded())))
            eggStat.setValue("\(egg)%")
        }
    }
    
    // MARK: - 나이 배지 설정
    private func applyAgeBadge(_ certification: String) {
        let value: String = {
            let t = certification.trimmingCharacters(in: .whitespacesAndNewlines)
            if t.isEmpty || t == "0" { return "ALL" }
            if t == "18" { return "19" }
            return t.uppercased()
        }()
        
        ageBadgeLabel.text = value
        
        switch value {
        case "ALL":
            ageBadgeLabel.backgroundColor = UIColor(red: 0.18, green: 0.73, blue: 0.33, alpha: 1.0)
            ageBadgeLabel.textColor = .white
        case "12":
            ageBadgeLabel.backgroundColor = UIColor(red: 0.96, green: 0.78, blue: 0.19, alpha: 1.0)
            ageBadgeLabel.textColor = .black
        case "15":
            ageBadgeLabel.backgroundColor = UIColor(red: 0.96, green: 0.55, blue: 0.16, alpha: 1.0)
            ageBadgeLabel.textColor = .white
        case "19":
            ageBadgeLabel.backgroundColor = UIColor(red: 0.88, green: 0.23, blue: 0.23, alpha: 1.0)
            ageBadgeLabel.textColor = .white
        default:
            ageBadgeLabel.backgroundColor = .gray
            ageBadgeLabel.textColor = .white
        }
    }
    
    // MARK: - 장르 설정
    private func genreText(from ids: [Int]?) -> String {
        guard let ids, !ids.isEmpty else { return "장르 정보 없음" }
        let map: [Int: String] = [
            28: "액션", 12: "모험", 16: "애니메이션", 35: "코미디",
            80: "범죄", 18: "드라마", 10749: "로맨스", 27: "공포",
            53: "스릴러", 878: "SF", 14: "판타지", 9648: "미스터리",
            36: "역사", 10752: "전쟁", 10402: "음악", 99: "다큐"
        ]
        let names = ids.prefix(3).compactMap { map[$0] }
        return names.isEmpty ? "장르 정보 없음" : names.joined(separator: ", ")
    }
}

// MARK: - 통계(예매율 / 누적관객수 / 에그지수) 아이콘 및 라벨 설정

// 예매율 / 누적관객수 / 에그지수 같은 정보를 보여주는 캡슐 형태 UIView
final class StatPillView: UIView {
    
    private let iconContainer = UIView().then {
        $0.backgroundColor = UIColor(white: 1.0, alpha: 0.10)
        $0.layer.cornerRadius = 26
        $0.clipsToBounds = true
    }
    
    private let iconView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .white
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .white.withAlphaComponent(0.75)
        $0.font = .systemFont(ofSize: 13, weight: .semibold)
        $0.numberOfLines = 2
        $0.textAlignment = .center
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.8
    }
    
    private let valueLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .boldSystemFont(ofSize: 24)
        $0.numberOfLines = 1
        $0.textAlignment = .center
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.8
    }
    
    init(iconSystemName: String, title: String) {
        super.init(frame: .zero)
        iconView.image = UIImage(systemName: iconSystemName)
        titleLabel.text = title
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup() {
        let vStack = UIStackView(arrangedSubviews: [iconContainer, titleLabel, valueLabel])
        vStack.axis = .vertical
        vStack.alignment = .center
        vStack.spacing = 10
        
        addSubview(vStack)
        vStack.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        iconContainer.addSubview(iconView)
        
        iconContainer.snp.makeConstraints {
            $0.width.height.equalTo(52)
        }
        
        iconView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(2)
        }
        
        valueLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(2)
        }
    }
    
    func setValue(_ text: String) {
        valueLabel.text = text
    }
}

// MARK: - 캡슐 모양 배지(ALL / 12 / 15 / 19) 라벨
final class PaddingLabel: UILabel {
    
    // 라벨 여백 설정
    var textInsets = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
    
    // 텍스트 그릴 때 여백 적용
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    // 라벨 크기 자동 조정
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + textInsets.left + textInsets.right,
            height: size.height + textInsets.top + textInsets.bottom
        )
    }
}
