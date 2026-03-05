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

        tabBar.tintColor = .red
        setupViewControllers()
    }

    private func setupViewControllers() {

        // 영화 목록 탭
        let movieList = MovieListViewController()
        let movieListNav = UINavigationController(rootViewController: movieList)
        movieListNav.tabBarItem = UITabBarItem(
            title: "영화 목록",
            image: UIImage(systemName: "film"),
            selectedImage: UIImage(systemName: "film.fill")
        )

        // 검색 탭
        let movieSearch = MovieSearchViewController()
        let movieSearchNav = UINavigationController(rootViewController: movieSearch)
        movieSearchNav.tabBarItem = UITabBarItem(
            title: "검색",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass.fill")
        )

        // 마이페이지 탭
        let myPage = MyPageViewController()
        let myPageNav = UINavigationController(rootViewController: myPage)
        myPageNav.tabBarItem = UITabBarItem(
            title: "마이페이지",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )

        viewControllers = [movieListNav, movieSearchNav, myPageNav]
    }
}



