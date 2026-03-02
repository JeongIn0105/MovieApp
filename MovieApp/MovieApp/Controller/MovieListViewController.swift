//
//  MovieListViewController.swift
//  MovieApp
//
//  Created by 이정인 on 2/27/26.
//

/*
 - 상단 **TabBar의 첫번째 화면**입니다.
 - 영화 이미지들은 좌우 스크롤 가능하도록 구현해주세요
 - API
     - https://developer.themoviedb.org/reference/movie-upcoming-list
 - 필수 기능 요소
     - `UICollectionView`를 활용하여 영화 포스터를 표시해주세요.
     - 사용자가 직접 상호 작용할 수 있는 다양한 기능을 제공해보세요.
 */

// MARK: 영화 목록 페이지 구현
import UIKit

final class MovieListViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "영화 목록"
    }
}


