//
//  MovieListViewController.swift
//  MovieApp
//
//  Created by 이정인 on 2/27/26.
//

/*
 - 상단 TabBar의 첫번째 화면입니다.
 - 영화 이미지들은 좌우 스크롤 가능하도록 구현해주세요
 - API
 - https://developer.themoviedb.org/reference/movie-upcoming-list
 - 필수 기능 요소
 - UICollectionView를 활용하여 영화 포스터를 표시해주세요.
 - 사용자가 직접 상호 작용할 수 있는 다양한 기능을 제공해보세요.
 */

// MARK: - 영화 목록 페이지 구현
import UIKit
import SnapKit
import Then

final class MovieListViewController: UIViewController {
    
    // MARK: - 섹션(Section)
    enum Section: Int, CaseIterable {
        case popular
        case nowPlaying
        case upcoming
        
        var title: String {
            switch self {
            case .popular: return "무비 차트"
            case .nowPlaying: return "현재 상영작"
            case .upcoming: return "상영 예정"
            }
        }
    }
    
    // MARK: - UIKit 셋팅
    private let titleLabel = UILabel().then {
        $0.text = "우이 무비"
        $0.font = .boldSystemFont(ofSize: 36)
        $0.textAlignment = .center
        $0.textColor = UIColor(red: 235/255, green: 6/255, blue: 6/255, alpha: 1.0)
    }
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: makeLayout()
    ).then {
        $0.backgroundColor = .systemBackground
        $0.showsVerticalScrollIndicator = false
        $0.contentInset = .init(top: 12, left: 0, bottom: 16, right: 0)
        $0.delegate = self
        $0.dataSource = self
        
        $0.register(MoviePosterCell.self,
                    forCellWithReuseIdentifier: MoviePosterCell.id)
        
        $0.register(SectionHeaderView.self,
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: SectionHeaderView.reuseId)
    }
    
    private let refreshControl = UIRefreshControl()
    
    // MARK: - 데이터
    private let service = TMDBService()
    private var moviesBySection: [Section: [Movie]] = [:]
    
    // MARK: - Lifecycle(생명주기)
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        configureUI()
        setupRefresh()
        fetchAll()
    }
    
    // MARK: - UI Setup
    private func configureUI() {
        
        [titleLabel, collectionView].forEach { view.addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(120)
            $0.centerX.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - 세로고침 설정
    private func setupRefresh() {
        refreshControl.addTarget(self,
                                 action: #selector(onRefresh),
                                 for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    @objc private func onRefresh() {
        fetchAll()
    }
    
    // MARK: - 네트워크 설정
    private func fetchAll() {
        let group = DispatchGroup() // DispatchGroup()은 여러 개의 비동기 작업이 모두 끝난 시점을 잡기 위한 도구.
        
        var popular: [Movie] = []
        var nowPlaying: [Movie] = []
        var upcoming: [Movie] = []
        var lastError: Error?
        
        refreshControl.beginRefreshing()
        
        // "무비 차트" 네트워크
        group.enter()
        service.fetchPopular { result in
            defer { group.leave() }
            if case .success(let list) = result { popular = list }
            if case .failure(let err) = result { lastError = err }
        }
        
        // "현재 상영작" 네트워크
        group.enter()
        service.fetchNowPlaying { result in
            defer { group.leave() }
            if case .success(let list) = result { nowPlaying = list }
            if case .failure(let err) = result { lastError = err }
        }
        
        // "상영 예정" 네트워크
        group.enter()
        service.fetchUpcoming { result in
            defer { group.leave() }
            if case .success(let list) = result { upcoming = list }
            if case .failure(let err) = result { lastError = err }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            
            self.refreshControl.endRefreshing()
            
            self.moviesBySection[.popular] = popular
            self.moviesBySection[.nowPlaying] = nowPlaying
            self.moviesBySection[.upcoming] = upcoming
            
            self.collectionView.reloadData()
            
            if let lastError {
                self.showErrorAlert(lastError)
            }
        }
    }
    
    private func showErrorAlert(_ error: Error) {
        let alert = UIAlertController(title: "네트워크 오류",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        alert.addAction(.init(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - 컬렉션 뷰 Layout 설정
    private func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(140),
                heightDimension: .absolute(210)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 8)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .estimated(140),
                heightDimension: .absolute(240)
            )
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            
            let layoutSection = NSCollectionLayoutSection(group: group)
            layoutSection.orthogonalScrollingBehavior = .continuous
            layoutSection.contentInsets = .init(top: 0, leading: 12, bottom: 16, trailing: 12)
            
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(44)
            )
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            
            layoutSection.boundarySupplementaryItems = [header]
            
            return layoutSection
        }
    }
}

// MARK: - 컬렉션 뷰 DataSource 설정
extension MovieListViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        return moviesBySection[section]?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MoviePosterCell.id,
            for: indexPath
        ) as? MoviePosterCell else {
            return UICollectionViewCell()
        }
        
        guard let section = Section(rawValue: indexPath.section),
              let movie = moviesBySection[section]?[indexPath.item] else {
            return cell
        }
        
        cell.configure(movie: movie, isFavorite: false)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionHeaderView.reuseId,
                for: indexPath
              ) as? SectionHeaderView,
              let sec = Section(rawValue: indexPath.section) else {
            return UICollectionReusableView()
        }
        
        header.configure(title: sec.title)
        return header
    }
}

// MARK: - 컬렉션 뷰 Delegate 설정
extension MovieListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        guard let section = Section(rawValue: indexPath.section),
              let movie = moviesBySection[section]?[indexPath.item] else { return }
        
        let alert = UIAlertController(
            title: movie.title,
            message: nil,
            preferredStyle: .alert
        )
        
        alert.addAction(.init(title: "닫기", style: .default))
        present(alert, animated: true)
    }
}


