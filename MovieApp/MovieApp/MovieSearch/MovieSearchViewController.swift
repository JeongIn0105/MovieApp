//
//  MovieSearchViewController.swift
//  MovieApp
//
//  Created by 이정인 on 3/2/26.
//

/*
 - 상단 TabBar의 두번째 화면입니다.
 - 검색창에 텍스트를 입력하고 검색 버튼 클릭시 해당 텍스트가 포함된 영화들을 보여주세요
 - UICollectionView를 활용하여 영화 포스터를 표시해주세요
 */

// MARK: - 영화 검색 페이지 구현
import UIKit
import SnapKit
import Then

final class MovieSearchViewController: UIViewController {

    private let service = TMDBService()

    // MARK: - 데이터
    private var defaultMovies: [Movie] = [] { didSet { reloadUI() } }
    private var searchResults: [Movie] = [] { didSet { reloadUI() } }

    // MARK: - 페이징(운영체제에서 메모리를 관리)
    private var isLoading = false

    private var defaultPage = 1
    private var defaultHasMore = true

    private var searchPage = 1
    private var searchHasMore = true

    private var searchWorkItem: DispatchWorkItem?

    // "검색 버튼을 눌렀는데 비어있음"일 때만 emptyLabel
    private var didTapSearchWithEmptyText = false { didSet { updateEmptyState() } }

    private var trimmedSearchText: String {
        (searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isSearching: Bool { !trimmedSearchText.isEmpty }

    private var currentMovies: [Movie] {
        isSearching ? searchResults : defaultMovies
    }

    // MARK: - UIKit 셋팅
    private let titleLabel = UILabel().then {
        $0.text = "우이 무비"
        $0.font = .boldSystemFont(ofSize: 36)
        $0.textAlignment = .center
        $0.textColor = UIColor(red: 235/255, green: 6/255, blue: 6/255, alpha: 1.0)
    }

    private let searchBar = UISearchBar().then {
        $0.placeholder = "검색어를 입력하세요"
        $0.searchBarStyle = .minimal
        $0.showsCancelButton = false
        $0.returnKeyType = .search
        $0.searchTextField.clearButtonMode = .whileEditing
    }

    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: makeLayout()
    ).then {
        $0.backgroundColor = .systemBackground
        $0.showsVerticalScrollIndicator = false
        $0.contentInset = .init(top: 12, left: 0, bottom: 16, right: 0)
        $0.keyboardDismissMode = .onDrag
        $0.delegate = self
        $0.dataSource = self
        $0.register(MoviePosterCell.self, forCellWithReuseIdentifier: MoviePosterCell.id)
    }

    private let emptyLabel = UILabel().then {
        $0.text = "검색 결과가 없습니다"
        $0.textAlignment = .center
        $0.textColor = .secondaryLabel
        $0.font = .systemFont(ofSize: 16, weight: .medium)
    }

    // MARK: - LifeCycle(생명주기)
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        searchBar.delegate = self

        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false

        setupLayout()
        updateEmptyState()

        // 탭 들어오면 기본(전체처럼) 목록 첫 페이지 로드
        defaultSearchPage()
    }

    // MARK: - 전체 레이아웃 설정
    private func setupLayout() {
        [titleLabel, searchBar, collectionView].forEach { view.addSubview($0) }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(120)
            $0.centerX.equalToSuperview()
        }

        searchBar.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(36)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            // 탭바(투명 블러)에 가리지 않게 safeArea로 설정.
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    // MARK: - 컬렉션 뷰 레이아웃 설정(3 columns)
    private func makeLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / 3.0),
            heightDimension: .estimated(260)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(260)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)

        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - Default (Discover)
    private func defaultSearchPage() {
        defaultPage = 1
        defaultHasMore = true
        defaultMovies = []
        fetchDefault(page: defaultPage, append: false)
    }

    private func fetchDefault(page: Int, append: Bool) {
        guard !isLoading, defaultHasMore else { return }
        isLoading = true

        service.fetchDiscover(page: page) { [weak self] result in
            guard let self else { return }
            self.isLoading = false

            switch result {
            case .success(let movies):
                // page 결과가 비면 더 없음
                if movies.isEmpty { self.defaultHasMore = false; return }

                if append {
                    self.defaultMovies.append(contentsOf: movies)
                } else {
                    self.defaultMovies = movies
                }

            case .failure:
                self.defaultHasMore = false
            }
        }
    }

    // MARK: - 검색 기능 설정
    private func loadSearchFirstPage(query: String) {
        searchPage = 1
        searchHasMore = true
        searchResults = []
        fetchSearch(query: query, page: searchPage, append: false)
    }

    private func fetchSearch(query: String, page: Int, append: Bool) {
        guard !isLoading, searchHasMore else { return }
        isLoading = true

        service.searchMovies(query: query, page: page) { [weak self] result in
            guard let self else { return }
            self.isLoading = false

            switch result {
            case .success(let movies):
                if movies.isEmpty { self.searchHasMore = false; return }

                if append {
                    self.searchResults.append(contentsOf: movies)
                } else {
                    self.searchResults = movies
                }

            case .failure:
                self.searchHasMore = false
                self.searchResults = []
            }
        }
    }

    // MARK: - 검색어가 비어있다면 실행하는 메서드
    private func reloadUI() {
        collectionView.reloadData()
        updateEmptyState()
    }

    private func updateEmptyState() {
        if didTapSearchWithEmptyText {
            collectionView.backgroundView = emptyLabel
            return
        }

        if isSearching && searchResults.isEmpty {
            collectionView.backgroundView = emptyLabel
            return
        }

        collectionView.backgroundView = nil
    }

    // MARK: - Debounce(이벤트를 그룹화하여 특정시간이 지난 후 하나의 이벤트만 발생)

    private func debounceSearch(_ text: String) { // 사용자가 검색창에 입력을 멈춘 후, 설정한 일정 시간(보통 300~500ms) 동안 추가 입력이 없을 때만 검색 API를 호출하는 기술.
        
        searchWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            self?.performSearch(text)
        }
        searchWorkItem = workItem

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: workItem)
    }
    
    // 검색을 수행하는 메서드
    private func performSearch(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // 검색어가 없으면 검색 결과 비우고 기본 리스트로 돌아감.
        guard !trimmed.isEmpty else {
            didTapSearchWithEmptyText = false
            searchResults = []
            updateEmptyState()
            return
        }

        didTapSearchWithEmptyText = false
        loadSearchFirstPage(query: trimmed)
    }
}

// MARK: - 컬렉션 뷰 DataSource 설정
extension MovieSearchViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        currentMovies.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MoviePosterCell.id,
            for: indexPath
        ) as? MoviePosterCell else {
            return UICollectionViewCell()
        }

        let movie = currentMovies[indexPath.item]
        cell.configure(movie: movie, isFavorite: false)
        return cell
    }
}

// MARK: - 컬렉션 뷰 Delegate 설정
extension MovieSearchViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = currentMovies[indexPath.item]
        let alert = UIAlertController(title: movie.title, message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: "닫기", style: .default))
        present(alert, animated: true)
    }

    // MARK: 무한 스크롤 트리거 설정
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentH = scrollView.contentSize.height
        let frameH = scrollView.frame.size.height

        // 바닥에서 300pt 남으면 다음 페이지 로드
        guard offsetY > contentH - frameH - 300 else { return }

        if isSearching {
            guard searchHasMore else { return }
            searchPage += 1
            fetchSearch(query: trimmedSearchText, page: searchPage, append: true)
        } else {
            guard defaultHasMore else { return }
            defaultPage += 1
            fetchDefault(page: defaultPage, append: true)
        }
    }
}

// MARK: - 서치 바 Delegate 설정
extension MovieSearchViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        debounceSearch(searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()

        let trimmed = trimmedSearchText
        if trimmed.isEmpty {
            didTapSearchWithEmptyText = true
            searchResults = []
            return
        }
        performSearch(trimmed)
    }
}
