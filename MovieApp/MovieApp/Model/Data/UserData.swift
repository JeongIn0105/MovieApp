//
//  UserData.swift
//  MovieApp
//
//  Created by 이정인 on 2/27/26.
//

import Foundation

// UserDefaults 저장/불러오기/로그인 검증을 한 곳에서 관리
final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private init() {}

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let id = "id"
        static let password = "password"
        static let name = "name"
        static let birthday = "birthday"
        static let phoneNumber = "phoneNumber"
    }

    // MARK: - Save
    func saveUser(id: String,
                  password: String,
                  name: String?,
                  birthday: String?,
                  phoneNumber: String?) {

        defaults.set(id, forKey: Keys.id)
        defaults.set(password, forKey: Keys.password)
        defaults.set(name, forKey: Keys.name)
        defaults.set(birthday, forKey: Keys.birthday)
        defaults.set(phoneNumber, forKey: Keys.phoneNumber)
    }

    // MARK: - Load
    func loadId() -> String? { defaults.string(forKey: Keys.id) }
    func loadPassword() -> String? { defaults.string(forKey: Keys.password) }
    func loadName() -> String? { defaults.string(forKey: Keys.name) }
    func loadBirthday() -> String? { defaults.string(forKey: Keys.birthday) }
    func loadPhoneNumber() -> String? { defaults.string(forKey: Keys.phoneNumber) }

    // MARK: - Login Validate
    func validateLogin(inputId: String, inputPassword: String) -> Bool {
        guard let savedId = loadId(),
              let savedPassword = loadPassword() else { return false }
        return savedId == inputId && savedPassword == inputPassword
    }

    // MARK: - Utils
    func trimmed(_ text: String?) -> String {
        (text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}


