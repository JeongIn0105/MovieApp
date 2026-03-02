//
//  MainTabBarViewController.swift
//  MovieApp
//
//  Created by 이정인 on 3/2/26.
//

// MARK: TarBar 화면으로 이동하면
import UIKit

final class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let movieList = UINavigationController(rootViewController: MovieListViewController())
        movieList.tabBarItem = UITabBarItem(title: "영화 목록", image: UIImage(systemName: "film"), tag: 0)
        
        let movieSearch = UINavigationController(rootViewController: MovieSearchViewController())
        movieSearch.tabBarItem = UITabBarItem(title: "영화 검색", image: UIImage(systemName: "magnifyingglass"), tag: 1)

        let myPage = UINavigationController(rootViewController: MyPageViewController())
        myPage.tabBarItem = UITabBarItem(title: "마이 페이지", image: UIImage(systemName: "person"), tag: 2)

        setViewControllers([movieList, movieSearch, myPage], animated: false)
    }
}
