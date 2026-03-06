    //
    //  BookingDetailViewController.swift
    //  MovieApp
    //

import UIKit
import SnapKit
import Then

    // MARK: - 티켓 유형
enum TicketType: String, CaseIterable {
    case adult    = "일반"
    case teen     = "청소년"
    case disabled = "우대"
    case senior   = "경로"

    var price: Int {
        switch self {
            case .adult:    return 15000
            case .teen:     return 12000
            case .disabled: return 8000
            case .senior:   return 9000
        }
    }
}

    // MARK: - BookingDetailViewController
final class BookingDetailViewController: UIViewController {

        // MARK: - 외부 주입
    var movieTitle: String = "영화"
    var posterImage: UIImage? = nil
    var ageRating: String = "ALL"

        // MARK: - 내부 상태
    private var ticketCounts: [TicketType: Int] = [
        .adult: 0, .teen: 0, .disabled: 0, .senior: 0
    ]
    private var selectedTimeLabel: String? = nil

    private let timeSlotLabels = ["09:00 ~ 11:00", "15:00 ~ 17:00", "17:00 ~ 19:00"]

    private var todayString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy.MM.dd"
        return fmt.string(from: Date())
    }

        // MARK: - UI
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
    }
    private let contentView = UIView()
    private let headerView = UIView().then { $0.backgroundColor = UIColor.systemGray5 }

    private let posterImageView = UIImageView().then {
        $0.backgroundColor = UIColor.systemGray4
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
    }
    private let movieTitleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.numberOfLines = 2
    }
    private let ageBadgeLabel = PaddingLabel().then {
        $0.font = .boldSystemFont(ofSize: 13)
        $0.textAlignment = .center
        $0.textInsets = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
    }
    private let dateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .darkGray
    }

    private let bottomCard = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.08
        $0.layer.shadowOffset = CGSize(width: 0, height: -2)
        $0.layer.shadowRadius = 8
    }

    private let personSectionLabel = UILabel().then {
        $0.text = "관람인원"
        $0.font = .systemFont(ofSize: 17, weight: .bold)
    }
    private let timeSectionLabel = UILabel().then {
        $0.text = "시간 선택"
        $0.font = .systemFont(ofSize: 17, weight: .bold)
    }
    private let timeStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.distribution = .fillEqually
    }
    private let totalLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15, weight: .semibold)
        $0.textColor = .systemGray
        $0.text = "인원을 선택해 주세요"
    }
    private let selectButton = UIButton().then {
        $0.setTitle("선택하기", for: .normal)
        $0.backgroundColor = UIColor(red: 0.93, green: 0.11, blue: 0.14, alpha: 1.0)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        $0.layer.cornerRadius = 12
    }

    private var ticketRows: [TicketRowView] = []
    private var timeButtons: [UIButton] = []

        // MARK: - Init
    init(movieTitle: String = "영화", posterImage: UIImage? = nil, ageRating: String = "ALL") {
        self.movieTitle = movieTitle
        self.posterImage = posterImage
        self.ageRating = ageRating
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

        // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGray5
        setupUI()
        movieTitleLabel.text = movieTitle
        dateLabel.text = "todayString"
        posterImageView.image = posterImage
        applyAgeBadge(ageRating)
    }

        // MARK: - UI 구성
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [headerView, bottomCard].forEach { contentView.addSubview($0) }
        [posterImageView, movieTitleLabel, ageBadgeLabel, dateLabel].forEach { headerView.addSubview($0) }

            // 티켓 스택
        let ticketStack = UIStackView().then { $0.axis = .vertical; $0.spacing = 12 }
        for type in TicketType.allCases {
            let row = TicketRowView(type: type)
            row.onChanged = { [weak self] in self?.handleTicketChange() }
            ticketRows.append(row)
            ticketStack.addArrangedSubview(row)
        }

            // 시간 버튼
        for (i, label) in timeSlotLabels.enumerated() {
            let btn = UIButton(type: .system)
            btn.setTitle(label, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
            btn.setTitleColor(.darkGray, for: .normal)
            btn.backgroundColor = UIColor.systemGray6
            btn.layer.cornerRadius = 8
            btn.layer.borderWidth = 1.5
            btn.layer.borderColor = UIColor.systemGray4.cgColor
            btn.tag = i
            btn.addTarget(self, action: #selector(timeButtonTapped(_:)), for: .touchUpInside)
            timeButtons.append(btn)
            timeStack.addArrangedSubview(btn)
        }

        [personSectionLabel, ticketStack, timeSectionLabel, timeStack, totalLabel, selectButton]
            .forEach { bottomCard.addSubview($0) }

            // Constraints
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.snp.makeConstraints { $0.edges.equalToSuperview(); $0.width.equalToSuperview() }

        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(240)
        }
        posterImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(110); $0.height.equalTo(160)
        }
        movieTitleLabel.snp.makeConstraints {
            $0.top.equalTo(posterImageView.snp.top).offset(8)
            $0.leading.equalTo(posterImageView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().inset(16)
        }
        ageBadgeLabel.snp.makeConstraints {
            $0.top.equalTo(movieTitleLabel.snp.bottom).offset(10)
            $0.leading.equalTo(movieTitleLabel.snp.leading)
            $0.height.equalTo(26)
        }
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(ageBadgeLabel.snp.bottom).offset(10)
            $0.leading.equalTo(movieTitleLabel.snp.leading)
        }

        bottomCard.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(-20)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        personSectionLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(28)
            $0.leading.equalToSuperview().inset(24)
        }
        ticketStack.snp.makeConstraints {
            $0.top.equalTo(personSectionLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        timeSectionLabel.snp.makeConstraints {
            $0.top.equalTo(ticketStack.snp.bottom).offset(28); $0.leading.equalToSuperview().inset(24)
        }
        timeStack.snp.makeConstraints {
            $0.top.equalTo(timeSectionLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(44)
        }
        totalLabel.snp.makeConstraints {
            $0.top.equalTo(timeStack.snp.bottom).offset(24); $0.leading.equalToSuperview().inset(24)
        }
        selectButton.snp.makeConstraints {
            $0.top.equalTo(totalLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(54)
            $0.bottom.equalToSuperview().inset(40)
        }
        selectButton.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
    }

        // MARK: - 티켓 인원 변경 및 총 금액 계산 로직
    private func handleTicketChange() {
            // 1. 각 티켓 타입별 선택된 수량을 dictionary에 업데이트
        ticketRows.forEach { ticketCounts[$0.ticketType] = $0.count }
            // 2. 고차함수(reduce)를 활용한 총 금액 및 총 인원 합산
        let total = ticketCounts.reduce(0) { $0 + $1.key.price * $1.value }
        let people = ticketCounts.values.reduce(0, +)
            // 3. UI 업데이트 (천 단위 콤마 포맷팅 적용)
        if people == 0 {
            totalLabel.text = "인원을 선택해 주세요"; totalLabel.textColor = .systemGray
        } else {
            let fmt = NumberFormatter(); fmt.numberStyle = .decimal
            totalLabel.text = "총 금액: \(fmt.string(from: NSNumber(value: total)) ?? "")원  (\(people)명)"
            totalLabel.textColor = .black
        }
    }

        // MARK: - 시간 버튼
    @objc private func timeButtonTapped(_ sender: UIButton) {
        selectedTimeLabel = timeSlotLabels[sender.tag]
        let red = UIColor(red: 0.93, green: 0.11, blue: 0.14, alpha: 1.0)
        timeButtons.forEach { btn in
            let on = btn.tag == sender.tag
            btn.backgroundColor = on ? red : UIColor.systemGray6
            btn.setTitleColor(on ? .white : .darkGray, for: .normal)
            btn.layer.borderColor = (on ? UIColor.clear : UIColor.systemGray4).cgColor
        }
    }

        // MARK: - 선택하기 → 좌석 선택
    @objc private func selectButtonTapped() {
        let people = ticketCounts.values.reduce(0, +)
        guard people > 0 else {
            alert("인원 선택", "관람인원을 1명 이상 선택해 주세요."); return
        }
        guard let time = selectedTimeLabel else {
            alert("시간 선택", "관람 시간을 선택해 주세요."); return
        }
        let seatVC = SeatSelectionViewController()
        seatVC.movieTitle    = movieTitle
        seatVC.movieDate     = "\(todayString) / \(time)"
        seatVC.posterImage   = posterImage
        seatVC.headCount     = people
        seatVC.ticketCounts  = ticketCounts
        seatVC.totalPrice    = ticketCounts.reduce(0) { $0 + $1.key.price * $1.value }
        seatVC.modalPresentationStyle = .fullScreen
        present(seatVC, animated: true)
    }

    private func alert(_ title: String, _ msg: String) {
        let a = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "확인", style: .default))
        present(a, animated: true)
    }

        // MARK: - 연령 배지
    private func applyAgeBadge(_ cert: String) {
        ageBadgeLabel.text = cert
        switch cert {
            case "ALL": ageBadgeLabel.backgroundColor = UIColor(red:0.18,green:0.73,blue:0.33,alpha:1)
                ageBadgeLabel.textColor = .white
            case "12":  ageBadgeLabel.backgroundColor = UIColor(red:0.96,green:0.78,blue:0.19,alpha:1)
                ageBadgeLabel.textColor = .black
            case "15":  ageBadgeLabel.backgroundColor = UIColor(red:0.96,green:0.55,blue:0.16,alpha:1)
                ageBadgeLabel.textColor = .white
            case "19":  ageBadgeLabel.backgroundColor = UIColor(red:0.88,green:0.23,blue:0.23,alpha:1)
                ageBadgeLabel.textColor = .white
            default:    ageBadgeLabel.backgroundColor = .gray
                ageBadgeLabel.textColor = .white
        }
    }
}

    // MARK: - 티켓 행 (유형명 + 가격 + 1~8 숫자 버튼)
final class TicketRowView: UIView {
    let ticketType: TicketType
    var count: Int = 0
    var onChanged: (() -> Void)?

    private let typeLabel  = UILabel().then { $0.font = .systemFont(ofSize: 18, weight: .semibold) }
    private let priceLabel = UILabel().then { $0.font = .systemFont(ofSize: 15); $0.textColor = .systemGray }
    private var numberButtons: [UIButton] = []
    private let buttonStack = UIStackView().then {
        $0.axis = .horizontal; $0.spacing = 6
        $0.distribution = .fillEqually
    }

    init(type: TicketType) {
        self.ticketType = type
        super.init(frame: .zero)
        typeLabel.text = type.rawValue
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        priceLabel.text = "\(fmt.string(from: NSNumber(value: type.price)) ?? "")원"
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
            // 1~8 숫자 버튼 생성
        for n in 1...8 {
            let btn = UIButton(type: .system)
            btn.setTitle("\(n)", for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
            btn.setTitleColor(.darkGray, for: .normal)
            btn.backgroundColor = .systemGray6
            btn.layer.cornerRadius = 6
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor.systemGray4.cgColor
            btn.tag = n
            btn.addTarget(self, action: #selector(numberTapped(_:)), for: .touchUpInside)
            numberButtons.append(btn)
            buttonStack.addArrangedSubview(btn)
        }

        let infoStack = UIStackView(arrangedSubviews: [typeLabel, priceLabel]).then {
            $0.axis = .vertical
            $0.spacing = 2
        }

        let container = UIStackView(arrangedSubviews: [infoStack, buttonStack]).then {
            $0.axis = .vertical
            $0.spacing = 8
        }

        addSubview(container)
        container.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)) }
        buttonStack.snp.makeConstraints { $0.height.equalTo(30) }
    }

    @objc private func numberTapped(_ sender: UIButton) {
        let selected = sender.tag
            // 같은 버튼 다시 누르면 선택 해제 (0으로)
        if count == selected {
            count = 0
            updateButtonUI(selected: 0)
        } else {
            count = selected
            updateButtonUI(selected: selected)
        }
        onChanged?()
    }

    private func updateButtonUI(selected: Int) {
        let red = UIColor(red: 0.93, green: 0.11, blue: 0.14, alpha: 1.0)
        numberButtons.forEach { btn in
            let on = btn.tag == selected
            btn.backgroundColor   = on ? red : .systemGray6
            btn.setTitleColor(on ? .white : .darkGray, for: .normal)
            btn.layer.borderColor = (on ? UIColor.clear : UIColor.systemGray4).cgColor
        }
    }
}
