//
//  SignUpViewController.swift
//  MovieApp
//
//  Created by 이정인 on 2/27/26.
//

// MARK: 회원가입 구현
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
        
        textField.text = UserDefaultsManager.shared.loadId()
        
        // textField.addTarget(self, action: #selector(idTextFieldChange(_:)), for: .editingChanged)
        
        return textField
        
    }()
    
    
    
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
        
        // textField.text = UserDefaultsManager.shared.loadPassword()
        
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
        
        // textField.text = UserDefaultsManager.shared.loadName()
        
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
        textField.textContentType = .none
        
        // textField.text = UserDefaultsManager.shared.loadBirthday()
        
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
        textField.textContentType = .telephoneNumber
        
        // textField.text = UserDefaultsManager.shared.loadPhoneNumber()
        
        return textField
        
    }()
    
    // MARK: 취소하기 버튼
    private let cancelButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("취소하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.backgroundColor = UIColor(red: 84/255, green: 146/255, blue: 232/255, alpha: 1.0)
        
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
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
        
        button.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureUI()
    }
    
    // MARK: 회원가입 화면 다시 들어올 때마다 항상 빈칸으로 구현
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearFields()
    }
    
    private func clearFields() {
        idTextField.text = ""
        passwordTextField.text = ""
        nameTextField.text = ""
        birthdayTextField.text = ""
        phoneNumberTextField.text = ""
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
        
        // MARK: 회원가입 화면의 제약 조건
        signUpLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(200)
            $0.centerX.equalToSuperview()
        }
        
        idTextField.snp.makeConstraints {
            $0.top.equalTo(signUpLabel.snp.bottom).offset(50)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(40)
        }
        
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
    
    // MARK: 취소하기 버튼을 클릭했을 때
    @objc
    private func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: 가입하기 버튼을 클릭했을 때
    @objc
    private func registerButtonTapped() {
        let id = UserDefaultsManager.shared.trimmed(idTextField.text)
        let password = UserDefaultsManager.shared.trimmed(passwordTextField.text)
        let name = UserDefaultsManager.shared.trimmed(nameTextField.text)
        let birthday = UserDefaultsManager.shared.trimmed(birthdayTextField.text)
        let phoneNumber = UserDefaultsManager.shared.trimmed(phoneNumberTextField.text)
        
        guard !id.isEmpty, !password.isEmpty else {
            showAlert(title: "입력 오류", message: "아이디와 비밀번호는 필수입니다.")
            return
        }
        
        // MARK: 회원가입 완료 → UserDefaults 저장.
        UserDefaultsManager.shared.saveUser(
            id: id,
            password: password,
            name: name.isEmpty ? nil : name,
            birthday: birthday.isEmpty ? nil : birthday,
            phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber
        )
        
        // MARK: 완료되면 다시 로그인 화면으로 이동(push가 아니라 pop)
        let register = UIAlertController(title: "회원가입 완료", message: "로그인 화면으로 이동합니다.", preferredStyle: .alert)
        register.addAction(UIAlertAction(title: "확인", style: .default, handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }))
        present(register, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
}
