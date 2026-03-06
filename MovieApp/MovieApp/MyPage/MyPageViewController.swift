//
//  MyPageViewController.swift
//  MovieApp
//

import UIKit
import SnapKit
import Then

final class MyPageViewController: UIViewController {

    // MARK: - Properties
    private let model = MyPageModel()
    private let pickerManager = PhotoPickerManager()
    private var completedList: [SavedReservation] = []
    private var cancelledList: [SavedReservation] = []
    private var showingCompleted = true

    // MARK: - UI
    private let titleLabel = UILabel().then {
        $0.text = "우이 무비"
        $0.font = .systemFont(ofSize: 28, weight: .bold)
        $0.textColor = UIColor(red: 235/255, green: 6/255, blue: 6/255, alpha: 1.0)
    }
    
    private let logoutButton = UIButton().then {
        $0.setTitle("로그아웃", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 20)
        $0.backgroundColor = .clear
        $0.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
    }
    
    private let myDataSectionLabel = UILabel().then {
        $0.text = "내 정보"; $0.font = .systemFont(ofSize: 22, weight: .bold)
    }
    private let profileImageView = UIImageView().then {
        $0.backgroundColor = .systemGray6; $0.layer.cornerRadius = 55
        $0.clipsToBounds = true; $0.contentMode = .scaleAspectFill
        $0.isUserInteractionEnabled = true
    }
    private let profilePlaceholderLabel = UILabel().then {
        $0.text = "프로필 사진"; $0.font = .systemFont(ofSize: 14, weight: .bold); $0.textColor = .systemGray4
    }
    private let infoStackView = UIStackView().then {
        $0.axis = .vertical; $0.spacing = 8; $0.alignment = .leading
    }
    private let nameLabel  = UILabel().then { $0.font = .systemFont(ofSize: 18, weight: .bold); $0.isUserInteractionEnabled = true }
    private let idLabel    = UILabel().then { $0.font = .systemFont(ofSize: 18, weight: .bold) }
    private let emailLabel = UILabel().then { $0.font = .systemFont(ofSize: 18, weight: .bold) }

    private let reservationSectionLabel = UILabel().then {
        $0.text = "예약 / 결제 내역"; $0.font = .systemFont(ofSize: 22, weight: .bold)
    }
    private let tabStackView = UIStackView().then { $0.axis = .horizontal; $0.spacing = 20 }

    private let paymentTabLabel = UILabel().then {
        $0.text = "결제 완료"; $0.font = .systemFont(ofSize: 18, weight: .bold); $0.textColor = .black
        $0.isUserInteractionEnabled = true
    }
    private let cancelTabLabel = UILabel().then {
        $0.text = "결제 취소"; $0.font = .systemFont(ofSize: 18, weight: .bold); $0.textColor = .systemGray3
        $0.isUserInteractionEnabled = true
    }

    // 탭 언더라인
    private let tabIndicator = UIView().then {
        $0.backgroundColor = UIColor(red: 235/255, green: 6/255, blue: 6/255, alpha: 1.0)
    }
    
    private let tableView = UITableView().then {
        $0.backgroundColor = UIColor.systemGray5
        $0.separatorStyle = .none
        $0.register(MyPageTableViewCell.self, forCellReuseIdentifier: MyPageTableViewCell.identifier)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        setupActions()
        tableView.dataSource = self
        tableView.delegate   = self
        setupPhotoHandler()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserData()
        reloadReservations()
    }

    // MARK: - Public: 결제 후 마이페이지로 돌아왔을 때 새로고침
    func reloadReservations() {
        completedList = ReservationStore.shared.loadCompleted()
        cancelledList = ReservationStore.shared.loadCancelled()
        tableView.reloadData()
    }

    // MARK: - Load User
    private func loadUserData() {
        let u = model.loadUserInfo()
        nameLabel.text = u.name; idLabel.text = u.id; emailLabel.text = u.email
        if let img = model.loadProfileImage() {
            profileImageView.image = img; profilePlaceholderLabel.isHidden = true
        }
    }

    // MARK: - Actions
    @objc private func didTapProfileImageView() { pickerManager.presentPicker(vc: self) }

    @objc private func didTapNameLabel() {
        let alert = UIAlertController(title: "이름 변경", message: "새로운 이름을 입력해주세요.", preferredStyle: .alert)
        alert.addTextField { [weak self] tf in tf.placeholder = "이름"; tf.text = self?.nameLabel.text }
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            guard let text = alert.textFields?.first?.text,
                  !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
            let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
            self?.model.updateName(t); self?.nameLabel.text = t
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func paymentTabTapped() {
        guard !showingCompleted else { return }
        showingCompleted = true
        updateTabUI()
        tableView.reloadData()
    }
    @objc private func cancelTabTapped() {
        guard showingCompleted else { return }
        showingCompleted = false
        updateTabUI()
        tableView.reloadData()
    }

    private func updateTabUI() {
        paymentTabLabel.textColor = showingCompleted ? .black : .systemGray3
        cancelTabLabel.textColor  = showingCompleted ? .systemGray3 : .black
        // 인디케이터 이동 (애니메이션)
        tabIndicator.snp.remakeConstraints { make in
            make.top.equalTo(tabStackView.snp.bottom).offset(4)
            make.height.equalTo(2)
            if showingCompleted {
                make.leading.equalTo(paymentTabLabel.snp.leading)
                make.width.equalTo(paymentTabLabel.snp.width)
            } else {
                make.leading.equalTo(cancelTabLabel.snp.leading)
                make.width.equalTo(cancelTabLabel.snp.width)
            }
        }
        UIView.animate(withDuration: 0.2) { self.view.layoutIfNeeded() }
    }

    private func setupPhotoHandler() {
        pickerManager.selectionHandler = { [weak self] img in
            guard let self else { return }
            UIView.transition(with: self.profileImageView, duration: 0.3, options: .transitionCrossDissolve) {
                self.profileImageView.image = img
                self.profilePlaceholderLabel.isHidden = true
            }
            self.model.saveProfileImage(img)
        }
    }
    
    private func setupActions() {
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapProfileImageView)))
        nameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapNameLabel)))
        paymentTabLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(paymentTabTapped)))
        cancelTabLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelTabTapped)))
    }

    // MARK: - Layout
    private func setupLayout() {
        [titleLabel, myDataSectionLabel, profileImageView, infoStackView,
         reservationSectionLabel, tabStackView, tabIndicator, tableView, logoutButton].forEach { view.addSubview($0) }

        profileImageView.addSubview(profilePlaceholderLabel)
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
      
        profilePlaceholderLabel.snp.makeConstraints { 
          $0.center.equalToSuperview() 
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
      
        tabIndicator.snp.makeConstraints {
            $0.top.equalTo(tabStackView.snp.bottom).offset(4)
            $0.leading.equalTo(paymentTabLabel.snp.leading)
            $0.width.equalTo(paymentTabLabel.snp.width)
            $0.height.equalTo(2)
        }
      
      logoutButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(80)
            $0.width.equalTo(80)
            $0.trailing.equalToSuperview().offset(-30)
        }
      
        tableView.snp.makeConstraints {
            $0.top.equalTo(tabIndicator.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func userUserDefaults() {
        let ud = UserDefaultsManager.shared

        // 저장된 값 읽기
        let savedName = ud.trimmed(ud.loadName())
        let savedId = ud.trimmed(ud.loadId())
        let savedEmail = ud.trimmed(ud.loadEmail())

        // 빈 값이면 "-" 처리
        let nameText = savedName.isEmpty ? "-" : savedName
        let idText = savedId.isEmpty ? "-" : savedId
        let emailText = savedEmail.isEmpty ? "-" : savedEmail

        // 라벨 업데이트
        nameLabel.text = "이름: \(nameText)"
        idLabel.text = "아이디: \(idText)"
        emailLabel.text = "이메일: \(emailText)"
    }
    
    // MARK: 로그아웃 버튼 실행
    @objc private func logoutButtonTapped() {
        
        let loginVC = LoginViewController()
        let nav = UINavigationController(rootViewController: loginVC)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = nav
            window.makeKeyAndVisible()
        }
    }
}

// MARK: - 테이블 뷰 Delegate, DataSource 설정
extension MyPageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let list = showingCompleted ? completedList : cancelledList
        return list.isEmpty ? 1 : list.count  // 빈 경우 안내 셀 1개
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let list = showingCompleted ? completedList : cancelledList

        // 데이터 없을 때 안내 셀
        if list.isEmpty {
            let cell = UITableViewCell()
            cell.backgroundColor = .clear
            cell.textLabel?.text = showingCompleted ? "결제 완료 내역이 없습니다." : "취소된 예매가 없습니다."
            cell.textLabel?.textColor = .systemGray
            cell.textLabel?.textAlignment = .center
            cell.selectionStyle = .none
            return cell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyPageTableViewCell.identifier, for: indexPath) as? MyPageTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: list[indexPath.row], isCancelled: !showingCompleted)

        // 취소 버튼 콜백 (결제 완료 탭에서만)
        if showingCompleted {
            cell.onCancelTapped = { [weak self] in
                self?.confirmCancel(reservation: list[indexPath.row])
            }
        } else {
            cell.onCancelTapped = nil
        }
        return cell
    }

    private func confirmCancel(reservation: SavedReservation) {
        let alert = UIAlertController(title: "예매 취소", message: "\"\(reservation.movieTitle)\" 예매를 취소하시겠어요?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소하기", style: .destructive) { [weak self] _ in
            ReservationStore.shared.cancel(id: reservation.id)
            self?.reloadReservations()
        })
        alert.addAction(UIAlertAction(title: "닫기", style: .cancel))
        present(alert, animated: true)
    }
}
