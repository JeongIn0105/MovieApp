//
//  MyPageViewController.swift
//  MovieApp
//
//  Created by 이정인 on 3/2/26.
//

/*
 - 상단 **TabBar의 세번째 화면**입니다.
 - 사용자의 정보와 관련된 기능을 모아서 제공하는 페이지를 자유롭게 만들어보세요.
 - 나의 필요한 계정 정보들을 표시해주세요(회원가입시 받은 정보들 활용)
 - 예매한 영화 내역을 볼 수 있도록 해주세요
 */

// MARK: 마이 페이지 구현
import UIKit

final class MyPageViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "마이 페이지"
    }
}
