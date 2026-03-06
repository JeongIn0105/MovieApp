//
//  LoginViewController.swift
//  MovieApp
//

import UIKit
import SnapKit
import Then

class LoginViewController: UIViewController {

    // MARK: - UI
    private let titleLabel = UILabel().then {
        $0.text = "우이 무비"
        $0.textColor = UIColor(red: 235/255, green: 6/255, blue: 6/255, alpha: 1.0)
        $0.font = .boldSystemFont(ofSize: 40)
    }

    private let IdTextField = UITextField().then {
        $0.borderStyle = .roundedRect
        $0.placeholder = "아이디"
        $0.textColor = UIColor(red: 255/255, green: 124/255, blue: 124/255, alpha: 1.0)
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
        $0.smartQuotesType = .no
        $0.textContentType = .username
    }

    private let PasswordTextField = UITextField().then {
        $0.borderStyle = .roundedRect
        $0.isSecureTextEntry = true
        $0.placeholder = "비밀번호"
        $0.textColor = UIColor(red: 255/255, green: 124/255, blue: 124/255, alpha: 1.0)
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
        $0.smartQuotesType = .no
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
        $0.addTarget(self, action: #selector(findIdTapped), for: .touchUpInside)
    }

    private let findPasswordButton = UIButton().then {
        $0.setTitle("비밀번호 찾기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 16)
        $0.backgroundColor = .clear
        $0.addTarget(self, action: #selector(findPasswordTapped), for: .touchUpInside)
    }

    private let signUpButton = UIButton().then {
        $0.setTitle("회원가입", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 16)
        $0.backgroundColor = .clear
        $0.addTarget(self, action: #selector(signUpButtonTapped), for: .touchDown)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IdTextField.text = UserDefaultsManager.shared.loadId()
        PasswordTextField.text = UserDefaultsManager.shared.loadPassword()
    }

    // MARK: - Layout
    private func setupLayout() {
        [titleLabel, IdTextField, PasswordTextField,
         loginButton, findIdButton, findPasswordButton, signUpButton]
            .forEach { view.addSubview($0) }

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

    // MARK: - Actions

    @objc private func loginButtonTapped() {
        let id       = UserDefaultsManager.shared.trimmed(IdTextField.text)
        let password = UserDefaultsManager.shared.trimmed(PasswordTextField.text)

        guard !id.isEmpty, !password.isEmpty else {
            showAlert(title: "입력 오류", message: "아이디와 비밀번호를 입력해주세요.")
            return
        }
        guard UserDefaultsManager.shared.validateLogin(inputId: id, inputPassword: password) else {
            showAlert(title: "로그인 실패", message: "아이디 또는 비밀번호가 올바르지 않습니다.\n(먼저 회원가입을 진행해주세요.)")
            return
        }
        UserDefaultsManager.shared.saveUser(
            id: id, password: password,
            name: UserDefaultsManager.shared.loadName(),
            birthday: UserDefaultsManager.shared.loadBirthday(),
            phoneNumber: UserDefaultsManager.shared.loadPhoneNumber(),
            email: UserDefaultsManager.shared.loadEmail()
        )
        let tabBar = MainTabBarViewController()
        navigationController?.setViewControllers([tabBar], animated: true)
    }

    // MARK: 아이디 찾기
    // 저장된 이름 + 전화번호로 아이디를 찾아줌
    @objc private func findIdTapped() {
        let alert = UIAlertController(title: "아이디 찾기",
                                      message: "가입 시 입력한 이름과 전화번호를 입력해주세요.",
                                      preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "이름"
            tf.autocapitalizationType = .none
        }
        alert.addTextField { tf in
            tf.placeholder = "전화번호"
            tf.keyboardType = .phonePad
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "찾기", style: .default) { [weak self] _ in
            guard let self else { return }
            let inputName  = (alert.textFields?[0].text ?? "").trimmingCharacters(in: .whitespaces)
            let inputPhone = (alert.textFields?[1].text ?? "").trimmingCharacters(in: .whitespaces)

            let savedName  = UserDefaultsManager.shared.loadName() ?? ""
            let savedPhone = UserDefaultsManager.shared.loadPhoneNumber() ?? ""
            let savedId    = UserDefaultsManager.shared.loadId() ?? ""

            if !inputName.isEmpty && !inputPhone.isEmpty
                && savedName == inputName && savedPhone == inputPhone {
                self.showAlert(title: "아이디 찾기 성공",
                               message: "회원님의 아이디는\n\"\(savedId)\" 입니다.")
            } else {
                self.showAlert(title: "찾기 실패",
                               message: "입력하신 정보와 일치하는\n계정을 찾을 수 없습니다.")
            }
        })
        present(alert, animated: true)
    }

    // MARK: 비밀번호 찾기
    // 저장된 아이디 + 이름으로 비밀번호를 찾아줌
    @objc private func findPasswordTapped() {
        let alert = UIAlertController(title: "비밀번호 찾기",
                                      message: "가입 시 입력한 아이디와 이름을 입력해주세요.",
                                      preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "아이디"
            tf.autocapitalizationType = .none
        }
        alert.addTextField { tf in
            tf.placeholder = "이름"
            tf.autocapitalizationType = .none
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "찾기", style: .default) { [weak self] _ in
            guard let self else { return }
            let inputId   = (alert.textFields?[0].text ?? "").trimmingCharacters(in: .whitespaces)
            let inputName = (alert.textFields?[1].text ?? "").trimmingCharacters(in: .whitespaces)

            let savedId       = UserDefaultsManager.shared.loadId() ?? ""
            let savedName     = UserDefaultsManager.shared.loadName() ?? ""
            let savedPassword = UserDefaultsManager.shared.loadPassword() ?? ""

            if !inputId.isEmpty && !inputName.isEmpty
                && savedId == inputId && savedName == inputName {
                // 비밀번호 재설정 팝업
                self.showResetPasswordAlert(currentPassword: savedPassword)
            } else {
                self.showAlert(title: "찾기 실패",
                               message: "입력하신 정보와 일치하는\n계정을 찾을 수 없습니다.")
            }
        })
        present(alert, animated: true)
    }

    // MARK: 비밀번호 재설정
    private func showResetPasswordAlert(currentPassword: String) {
        let alert = UIAlertController(title: "비밀번호 재설정",
                                      message: "새로운 비밀번호를 입력해주세요.",
                                      preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "새 비밀번호"
            tf.isSecureTextEntry = true
        }
        alert.addTextField { tf in
            tf.placeholder = "새 비밀번호 확인"
            tf.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "변경", style: .default) { [weak self] _ in
            guard let self else { return }
            let newPw     = alert.textFields?[0].text ?? ""
            let confirmPw = alert.textFields?[1].text ?? ""

            guard !newPw.isEmpty else {
                self.showAlert(title: "오류", message: "비밀번호를 입력해주세요."); return
            }
            guard newPw == confirmPw else {
                self.showAlert(title: "오류", message: "비밀번호가 일치하지 않습니다."); return
            }
            // 저장
            UserDefaultsManager.shared.saveUser(
                id:          UserDefaultsManager.shared.loadId() ?? "",
                password:    newPw,
                name:        UserDefaultsManager.shared.loadName(),
                birthday:    UserDefaultsManager.shared.loadBirthday(),
                phoneNumber: UserDefaultsManager.shared.loadPhoneNumber(),
                email:       UserDefaultsManager.shared.loadEmail()
            )
            self.showAlert(title: "변경 완료", message: "비밀번호가 성공적으로 변경되었습니다.")
        })
        present(alert, animated: true)
    }

    @objc private func signUpButtonTapped() {
        navigationController?.pushViewController(SignUpViewController(), animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
