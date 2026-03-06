//
//  MyPageModel.swift
//  MovieApp
//
//  Created by t2025-m0239 on 2026.03.05.
//

import UIKit

// MARK: - Data Model
struct ReservationData {
    let movieName: String
    let dateTime: String
    let price: String
}

// MARK: - MyPageModel (프로필 이미지 저장/불러오기)
final class MyPageModel {

    private let profileImageKey = "user_profile_image"

    // 이미지 저장
    func saveProfileImage(_ image: UIImage) {
        if let data = image.pngData() {
            UserDefaults.standard.set(data, forKey: profileImageKey)
        }
    }

    // 이미지 불러오기
    func loadProfileImage() -> UIImage? {
        guard let data = UserDefaults.standard.data(forKey: profileImageKey),
              let image = UIImage(data: data) else { return nil }
        return image
    }

    // UserDefaultsManager로부터 유저 정보 불러오기
    func loadUserInfo() -> (name: String, id: String, email: String) {
        let manager = UserDefaultsManager.shared
        let name = manager.loadName() ?? "이름을 입력해주세요"
        let id = manager.loadId() ?? "아이디"
        let email = manager.loadEmail() ?? "이메일"
        return (name, id, email)
    }

    // 이름 저장 (기존 유저 데이터 유지하면서 이름만 업데이트)
    func updateName(_ name: String) {
        let manager = UserDefaultsManager.shared
        manager.saveUser(
            id: manager.loadId() ?? "",
            password: manager.loadPassword() ?? "",
            name: name,
            birthday: manager.loadBirthday(),
            phoneNumber: manager.loadPhoneNumber(),
            email: manager.loadEmail()
        )
    }
}
