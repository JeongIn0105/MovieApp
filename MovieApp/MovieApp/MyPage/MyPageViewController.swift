//
//  MyPageViewController.swift
//  MovieApp
//
//  Created by t2025-m0239 on 2026.03.05.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class MyPageViewController: UIViewController {

        // MARK: - Properties
    private let pickerManager = PhotoPickerManager()
    private let dataSource: [ReservationData] = [
        ReservationData(movieName: "파묘", dateTime: "2026.03.04 / 14:00", price: "15,000 원"),
        ReservationData(movieName: "듄: 파트2", dateTime: "2026.03.05 / 18:30", price: "18,000 원")
    ]

        // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.text = "우이 무비"
        $0.font = .systemFont(ofSize: 28, weight: .bold)
        $0.textColor = UIColor(red: 235/255, green: 6/255, blue: 6/255, alpha: 1.0)
    }

    private let myDataSectionLabel = UILabel().then {
        $0.text = "내 정보"
        $0.font = .systemFont(ofSize: 22, weight: .bold)
    }

    private let profileImageView = UIImageView().then {
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 55
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
        $0.isUserInteractionEnabled = true
    }

    private let infoStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .leading
    }

    private let nameLabel = UILabel().then {
        $0.text = "이름"
        $0.font = .systemFont(ofSize: 18, weight: .bold)
    }

    private let idLabel = UILabel().then {
        $0.text = "아이디"
        $0.font = .systemFont(ofSize: 18, weight: .bold)
    }

    private let emailLabel = UILabel().then {
        $0.text = "이메일"
        $0.font = .systemFont(ofSize: 18, weight: .bold)
    }

    private let reservationSectionLabel = UILabel().then {
        $0.text = "예약 / 결제 내역"
        $0.font = .systemFont(ofSize: 22, weight: .bold)
    }

    private let tabStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 20
    }

    private let paymentTabLabel = UILabel().then {
        $0.text = "결제 완료"
        $0.font = .systemFont(ofSize: 18, weight: .bold)
        $0.textColor = .black
    }

    private let cancelTabLabel = UILabel().then {
        $0.text = "결제 취소"
        $0.font = .systemFont(ofSize: 18, weight: .bold)
        $0.textColor = .systemGray3
    }

    private let tableView = UITableView().then {
        $0.backgroundColor = UIColor.systemGray5
        $0.separatorStyle = .none
        $0.register(MyPageTableViewCell.self, forCellReuseIdentifier: MyPageTableViewCell.identifier)
    }

        // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        setupActions()
        setupTableView()
        setupPhotoHandler()
    }

    private func setupPhotoHandler() {
        pickerManager.selectionHandler = { [weak self] image in
            guard let self = self else { return }
            UIView.transition(with: self.profileImageView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.profileImageView.image = image
            }, completion: nil)
        }
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    @objc private func didTapProfileImageView() {
        pickerManager.presentPicker(vc: self)
    }

    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImageView))
        profileImageView.addGestureRecognizer(tapGesture)
    }

    private func setupLayout() {
        [titleLabel, myDataSectionLabel, profileImageView, infoStackView,
         reservationSectionLabel, tabStackView, tableView].forEach {
            view.addSubview($0)
        }

        [nameLabel, idLabel, emailLabel].forEach { infoStackView.addArrangedSubview($0) }
        [paymentTabLabel, cancelTabLabel].forEach { tabStackView.addArrangedSubview($0) }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(80)
            $0.centerX.equalToSuperview()
        }

        myDataSectionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(40)
        }

        profileImageView.snp.makeConstraints {
            $0.top.equalTo(myDataSectionLabel.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(110)
        }

        infoStackView.snp.makeConstraints {
            $0.centerY.equalTo(profileImageView)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(20)
        }

        reservationSectionLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }

        tabStackView.snp.makeConstraints {
            $0.top.equalTo(reservationSectionLabel.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(20)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(tabStackView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

    // MARK: - UITableView Extensions
extension MyPageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyPageTableViewCell.identifier, for: indexPath) as? MyPageTableViewCell else {
            return UITableViewCell()
        }
        let data = dataSource[indexPath.row]
        cell.configure(with: data)
        return cell
    }
}

