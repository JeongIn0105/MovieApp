//
//  SignUpViewController.swift
//  MovieApp
//
//  Created by 이정인 on 2/27/26.
//

import UIKit
import SnapKit

class SignUpViewController: UIViewController {
    
    // MARK: 회원가입 라벨
    private let signUpLabel: UILabel = {
        
        let label = UILabel()
        label.text = "회원가입"
        label.textColor = UIColor(red: 235/255, green: 6/255, blue: 6/255, alpha: 1.0)
        label.font = .boldSystemFont(ofSize: 40)
        
        return label
        
    }()
    
    // MARK: 아이디 입력란
    private let idTextField: UITextField = {
        
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "아이디"
        textField.autocapitalizationType = .none // 자동 대문자 변환 무시
        textField.autocorrectionType = .no // 자동 수정 무시
        textField.smartQuotesType = .no // 스마트 구두점 무시
        textField.textContentType = .username
        
        // textField.addTarget(self, action: #selector(idTextFieldChange(_:)), for: .editingChanged)
        
        return textField
        
    }()
    
    /*
    // MARK: 중복확인 버튼
    private let checkIdButton: UIButton = {
        
        let button = UIButton()
        button.setTitle("중복 확인", for: .normal)
        button.isEnabled = false
        button.setTitleColor(.systemGray5, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        button.layer.cornerRadius = 7
        button.backgroundColor = .systemGray6

        return button
        
    }()
    */
    
    // MARK: 비밀번호 입력란
    private let passwordTextField: UITextField = {
        
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
    
    // MARK: 이름 입력란
    private let nameTextField: UITextField = {
        
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "이름"
        textField.autocapitalizationType = .none // 자동 대문자 변환 무시
        textField.autocorrectionType = .no // 자동 수정 무시
        textField.smartQuotesType = .no // 스마트 구두점 무시
        textField.textContentType = .name
        
        return textField
        
    }()
    
    // MARK: 생년월일 입력란
    private let birthdayTextField: UITextField = {
        
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "년도. 월. 일."
        textField.autocapitalizationType = .none // 자동 대문자 변환 무시
        textField.autocorrectionType = .no // 자동 수정 무시
        textField.smartQuotesType = .no // 스마트 구두점 무시
        textField.textContentType = .name
        
        return textField
        
    }()
    
    // MARK: 전화번호 입력란
    private let phoneNumberTextField: UITextField = {
        
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "전화번호 - 없이 입력"
        textField.autocapitalizationType = .none // 자동 대문자 변환 무시
        textField.autocorrectionType = .no // 자동 수정 무시
        textField.smartQuotesType = .no // 스마트 구두점 무시
        textField.textContentType = .name
        
        return textField
        
    }()
    
    // MARK: 취소하기 버튼
    private let cancelButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("취소하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.backgroundColor = UIColor(red: 84/255, green: 146/255, blue: 232/255, alpha: 1.0)
        
        button.layer.cornerRadius = 16
        
        return button
    }()

    // MARK: 가입하기 버튼
    private let registerButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("가입하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.backgroundColor = UIColor(red: 255/255, green: 124/255, blue: 124/255, alpha: 1.0)
        
        button.layer.cornerRadius = 16
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureUI()
    }
    
    private func configureUI() {
        
        view.backgroundColor = .white
        
        [
            signUpLabel,
            idTextField,
            passwordTextField,
            nameTextField,
            birthdayTextField,
            phoneNumberTextField,
            cancelButton,
            registerButton
        ].forEach { view.addSubview($0) }
        
        signUpLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(200)
            $0.centerX.equalToSuperview()
        }
        
        idTextField.snp.makeConstraints {
            $0.top.equalTo(signUpLabel.snp.bottom).offset(50)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(40)
        }
        
        // 중복버튼 제약 조건
        /*
        checkIdButton.snp.makeConstraints {
            $0.top.equalTo(idTextField)
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.equalTo(100)
            $0.height.equalTo(40)
        }
        */
        
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(idTextField.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(40)
        }
        
        nameTextField.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(40)
        }
        
        birthdayTextField.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(40)
        }
        
        phoneNumberTextField.snp.makeConstraints {
            $0.top.equalTo(birthdayTextField.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(40)
        }
        
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(phoneNumberTextField.snp.bottom).offset(50)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(58)
        }

        registerButton.snp.makeConstraints {
            $0.top.equalTo(cancelButton)
            $0.leading.equalTo(cancelButton.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.equalTo(cancelButton)
            $0.height.equalTo(58)
        }
        
    }
    
    /*
    // MARK: 아이디를 입력하면 중복 버튼 활성화
    @objc
    private func idTextFieldChange(_: UITextField) {
        
        let input = idTextField.text ?? ""
        let inputtext = input.trimmingCharacters(in: .whitespacesAndNewlines)

        if input != inputtext { // 좌우에 공백이 들어오면 비활성화
            checkButtonDisable()
            return
        }

        if input.isEmpty { // 비어있으면 버튼 비활성화
            checkButtonDisable()
        } else { // 셀에 내용이 있으면 버튼 활성화
            checkButtonEnable()
        }
    }
    
    // 중복 확인 버튼 활성화
    private func checkButtonEnable() {
        checkIdButton.isEnabled = true
        checkIdButton.setTitleColor(.systemBackground, for: .normal)
        checkIdButton.backgroundColor = .systemRed
    }

    // 중복 확인 버튼 비활성화
    private func checkButtonDisable() {
        checkIdButton.isEnabled = false
        checkIdButton.setTitleColor(.systemGray3, for: .normal)
        checkIdButton.backgroundColor = .systemGray6
    }
    */
    
}

extension SignUpViewController {
    
}
