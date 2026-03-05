//
//  MainTabBarViewController.swift
//  MovieApp
//
//  Created by 이정인 on 3/2/26.
//

// MARK: - TabBar 화면으로 이동하면
import UIKit

final class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.tintColor = .red // TapBar 아이템 선택 색상 설정
        setupViewControllers() // 뷰 컨트롤러 설정

    }
    
    // MARK: TabBar에 표시할 네비게이션 컨트롤러들 초기화
    private func setupViewControllers() {
        
        // 홈 탭
        let moveList = MovieListViewController()
        let moveListNav = UINavigationController(rootViewController: moveList)
        
        moveListNav.tabBarItem = UITabBarItem(
            title: "영화 목록",
            image: UIImage(systemName: "film"),
            selectedImage: UIImage(systemName: "film.fill")
        )
        moveListNav.isNavigationBarHidden = true // 홈 화면에서는 네비게이션 바 숨김

        // 검색 탭
        let movieSearch = MovieSearchViewController()
        // movieSearch.title = "영화 검색"
        let movieSearchNav = UINavigationController(rootViewController: movieSearch)
        
        movieSearchNav.tabBarItem = UITabBarItem(
            title: "검색",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass.fill")
        )

        // 마이 페이지 탭
        let myPage = MyPageViewController()

        let myPageNav = UINavigationController(rootViewController: myPage)
        
        myPageNav.tabBarItem = UITabBarItem(
            title: "마이페이지",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        myPageNav.isNavigationBarHidden = false // 마이페이지 화면에서는 네비게이션 바 표시

        // 탭바에 뷰 컨트롤러들 추가
        viewControllers = [moveListNav, movieSearchNav, myPageNav]
    }
}



