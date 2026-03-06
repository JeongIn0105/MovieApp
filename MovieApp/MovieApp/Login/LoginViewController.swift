//
//  LoginViewController.swift
//  MovieApp
//
//  Created by 이정인 on 2/27/26.
//

// MARK: - 로그인 구현
import UIKit
import SnapKit
import Then

class LoginViewController: UIViewController {
    
    // MARK: 제목 라벨
    private let titleLabel = UILabel().then {
        
        $0.text = "우이 무비"
        $0.textColor = UIColor(red: 235/255, green: 6/255, blue: 6/255, alpha: 1.0)
        $0.font = .boldSystemFont(ofSize: 40)
        
    }
    
    // MARK: 아이디 입력란
    private let IdTextField = UITextField().then {
        
        $0.borderStyle = .roundedRect
        $0.placeholder = "아이디"
        $0.textColor = UIColor(red: 255/255, green: 124/255, blue: 124/255, alpha: 1.0)
        $0.autocapitalizationType = .none // 자동 대문자 변환 무시
        $0.autocorrectionType = .no // 자동 수정 무시
        $0.smartQuotesType = .no // 스마트 구두점 무시
        $0.textContentType = .username
        
    }
    
    // MARK: 비밀번호 입력란
    private let PasswordTextField = UITextField().then {
        
        $0.borderStyle = .roundedRect
        $0.isSecureTextEntry = true
        $0.placeholder = "비밀번호"
        $0.textColor = UIColor(red: 255/255, green: 124/255, blue: 124/255, alpha: 1.0)
        $0.autocapitalizationType = .none // 자동 대문자 변환 무시
        $0.autocorrectionType = .no // 자동 수정 무시
        $0.smartQuotesType = .no // 스마트 구두점 무시
        $0.textContentType = .password
        
    }
    
    private lazy var loginButton = UIButton().then {
        
        $0.setTitle("로그인", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 20)
        $0.backgroundColor = UIColor(red: 255/255, green: 124/255, blue: 124/255, alpha: 1.0)
        $0.layer.cornerRadius = 16
        
        $0.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
    }
    
    private let findIdButton = UIButton().then {
        
        $0.setTitle("아이디 찾기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 16)
        $0.backgroundColor = .clear
        
    }
    
    private let findPasswordButton = UIButton().then {
        
        $0.setTitle("비밀번호 찾기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 16)
        $0.backgroundColor = .clear
        
    }
    
    private let signUpButton = UIButton().then {
        
        $0.setTitle("회원가입", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 16)
        $0.backgroundColor = .clear
        
        $0.addTarget(self, action: #selector(signUpButtonTapped), for: .touchDown)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        [
            titleLabel,
            IdTextField,
            PasswordTextField,
            loginButton,
            findIdButton,
            findPasswordButton,
            signUpButton
        ].forEach { view.addSubview($0) }
        
        // MARK: 로그인 화면의 제약 조건
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(250)
            $0.centerX.equalToSuperview()
        }
        
        IdTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(45)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(40)
        }
        
        PasswordTextField.snp.makeConstraints {
            $0.top.equalTo(IdTextField.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(40)
        }
        
        loginButton.snp.makeConstraints {
            $0.top.equalTo(PasswordTextField.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(50)
        }
        
        findIdButton.snp.makeConstraints {
            $0.top.equalTo(loginButton.snp.bottom).offset(30)
            $0.leading.equalToSuperview().inset(60)
            $0.height.equalTo(15)
        }
        
        findPasswordButton.snp.makeConstraints {
            $0.top.equalTo(loginButton.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(15)
        }
        
        signUpButton.snp.makeConstraints {
            $0.top.equalTo(loginButton.snp.bottom).offset(30)
            $0.trailing.equalToSuperview().inset(60)
            $0.height.equalTo(15)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("viewWillAppear")
        
        IdTextField.text = UserDefaultsManager.shared.loadId()
        PasswordTextField.text = UserDefaultsManager.shared.loadPassword()
        
    }
    
    // MARK: 로그인 버튼을 클릭했을 때
    @objc
    private func loginButtonTapped() {
        let id = UserDefaultsManager.shared.trimmed(IdTextField.text)
        let password = UserDefaultsManager.shared.trimmed(PasswordTextField.text)
        
        guard !id.isEmpty, !password.isEmpty else {
            showAlert(title: "입력 오류", message: "아이디와 비밀번호를 입력해주세요.")
            return
        }
        
        // MARK: 저장된 회원정보와 비교
        guard UserDefaultsManager.shared.validateLogin(inputId: id, inputPassword: password) else {
            showAlert(title: "로그인 실패", message: "아이디 또는 비밀번호가 올바르지 않습니다.\n(먼저 회원가입을 진행해주세요.)")
            return
        }

        // MARK: 로그인 완료 → TabBar 화면 이동
        let tabBar = MainTabBarViewController()
        navigationController?.setViewControllers([tabBar], animated: true)
        
    }
    
    // MARK: 회원가입 버튼을 클릭했을 때
    @objc
    private func signUpButtonTapped() {
        self.navigationController?.pushViewController(SignUpViewController(), animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
}
