//
//  MovieSearchViewController.swift
//  MovieApp
//
//  Created by 이정인 on 3/2/26.
//

/*
 - 상단 TabBar의 두번째 화면입니다.
 - 검색창에 텍스트를 입력하고 검색 버튼 클릭시 해당 텍스트가 포함된 영화들을 보여주세요
 - UICollectionView를 활용하여 영화 포스터를 표시해주세요.
 */

// MARK: 영화 검색 페이지 구현
import UIKit

final class MovieSearchViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "영화 검색"
    }
}
