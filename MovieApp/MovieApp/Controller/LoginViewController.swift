//
//  LoginViewController.swift
//  MovieApp
//
//  Created by 이정인 on 2/27/26.
//


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
    
    // 회원가입 글자 |
    private let deviderLabel: UILabel = {
        
        let label = UILabel()
        label.text = "|"
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = .secondaryLabel
        
        return label
    }()
    
    private let signUpButton: UIButton = {
        
        let button = UIButton()
        button.setTitle("회원가입", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = .clear
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchDown)
        
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
        
    }
    
    
    @objc
    private func buttonTapped() {
        self.navigationController?.pushViewController(SignUpViewController(), animated: true)
    }

}
