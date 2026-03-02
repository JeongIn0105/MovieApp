//
//  LoginViewController.swift
//  MovieApp
//
//  Created by 이정인 on 2/27/26.
//

// MARK: 로그인 구현
import UIKit
import SnapKit

class LoginViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        
        let label = UILabel()
        label.text = "우이 무비"
        label.textColor = UIColor(red: 235/255, green: 6/255, blue: 6/255, alpha: 1.0)
        label.font = .boldSystemFont(ofSize: 40)
        
        return label
        
    }()
    
    // MARK: 아이디 입력란
    private let IdTextField: UITextField = {
        
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "아이디"
        textField.textColor = UIColor(red: 255/255, green: 124/255, blue: 124/255, alpha: 1.0)
        textField.autocapitalizationType = .none // 자동 대문자 변환 무시
        textField.autocorrectionType = .no // 자동 수정 무시
        textField.smartQuotesType = .no // 스마트 구두점 무시
        textField.textContentType = .username
        
        return textField
        
    }()
    
    // MARK: 비밀번호 입력란
    private let PasswordTextField: UITextField = {
        
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.placeholder = "비밀번호"
        textField.textColor = UIColor(red: 255/255, green: 124/255, blue: 124/255, alpha: 1.0)
        textField.autocapitalizationType = .none // 자동 대문자 변환 무시
        textField.autocorrectionType = .no // 자동 수정 무시
        textField.smartQuotesType = .no // 스마트 구두점 무시
        textField.textContentType = .password
        
        return textField
        
    }()
    
    private lazy var loginButton: UIButton = {
        
        let button = UIButton()
        button.setTitle("로그인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.backgroundColor = UIColor(red: 255/255, green: 124/255, blue: 124/255, alpha: 1.0)
        button.layer.cornerRadius = 16
        
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private let findIdButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("아이디 찾기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = .clear
        
        return button
        
    }()
    
    private let findPasswordButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("비밀번호 찾기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = .clear
        
        return button
        
    }()
    
    private let signUpButton: UIButton = {
        
        let button = UIButton()
        button.setTitle("회원가입", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = .clear
        
        button.addTarget(self, action: #selector(signUpButtonTapped), for: .touchDown)
        
        return button
    }()
    
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
        
        // IdTextField.text = UserDefaultsManager.shared.loadId()
        // PasswordTextField.text = UserDefaultsManager.shared.loadPassword()
        
        IdTextField.text = ""
        PasswordTextField.text = ""
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
        
        // MARK: 로그인 성공 시에도 다시 저장(요구사항: 이후 자동 입력)
        UserDefaultsManager.shared.saveUser(
            id: id,
            password: password,
            name: UserDefaultsManager.shared.loadName(),
            birthday: UserDefaultsManager.shared.loadBirthday(),
            phoneNumber: UserDefaultsManager.shared.loadPhoneNumber()
        )
        
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
