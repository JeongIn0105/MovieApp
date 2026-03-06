//
//  SeatSelectionViewController.swift
//  MovieApp
//

import UIKit
import SnapKit
import Then

final class SeatSelectionViewController: UIViewController {

    // MARK: - 외부 주입
    var movieTitle: String    = ""
    var movieDate: String     = ""
    var posterImage: UIImage? = nil
    var headCount: Int        = 1
    var ticketCounts: [TicketType: Int] = [:]
    var totalPrice: Int       = 0

    private let mainView = SeatSelectionView()
    private var selectedSeats: [Seat] = []

    override func loadView() { view = mainView }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollViewDelegate()
        mainView.seatMapView.onSeatTapped = { [weak self] ip in self?.handleSeatTap(at: ip) }
        mainView.closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        mainView.confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let sv      = mainView.scrollView
        let mapSize = mainView.seatMapView.intrinsicContentSize
        let vsz     = sv.bounds.size
        guard vsz.width > 0 else { return }
        let scale = min(vsz.width / mapSize.width, vsz.height / mapSize.height, 1.0)
        sv.minimumZoomScale = max(0.4, scale * 0.75)
        if sv.zoomScale == 1.0 { sv.zoomScale = scale }
        let ox = max(0, (mapSize.width  * scale - vsz.width)  / 2)
        let oy = max(0, (mapSize.height * scale - vsz.height) / 2)
        sv.setContentOffset(CGPoint(x: ox, y: oy), animated: false)
    }

    private func setupScrollViewDelegate() { mainView.scrollView.delegate = self }

    // MARK: - 좌석 탭
    private func handleSeatTap(at indexPath: IndexPath) {
        let r = indexPath.section, c = indexPath.item
        guard r < mainView.seatMapView.seats.count,
              c < mainView.seatMapView.seats[r].count else { return }
        let seat = mainView.seatMapView.seats[r][c]
        guard !seat.isOccupied else { shake(); return }

        if !seat.isSelected && selectedSeats.count >= headCount {
            let a = UIAlertController(title: "좌석 초과",
                                      message: "선택 인원(\(headCount)명)만큼만 고를 수 있어요.",
                                      preferredStyle: .alert)
            a.addAction(UIAlertAction(title: "확인", style: .default))
            present(a, animated: true); return
        }
        mainView.seatMapView.seats[r][c].isSelected.toggle()
        if mainView.seatMapView.seats[r][c].isSelected {
            selectedSeats.append(mainView.seatMapView.seats[r][c])
        } else {
            selectedSeats.removeAll { $0.label == seat.label }
        }
        mainView.updateSelectionUI(selectedSeats: selectedSeats, maxCount: headCount)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func shake() {
        let a = CAKeyframeAnimation(keyPath: "transform.translation.x")
        a.values = [0,-6,6,-4,4,-2,2,0]; a.duration = 0.35
        mainView.seatMapView.layer.add(a, forKey: "shake")
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    @objc private func closeTapped() { dismiss(animated: true) }

    // MARK: - 선택 완료 → 결제 모달
    @objc private func confirmTapped() {
        guard !selectedSeats.isEmpty else { return }
        guard selectedSeats.count == headCount else {
            let a = UIAlertController(title: "좌석 미선택",
                                      message: "\(headCount)석을 모두 선택해 주세요. (현재 \(selectedSeats.count)석)",
                                      preferredStyle: .alert)
            a.addAction(UIAlertAction(title: "확인", style: .default))
            present(a, animated: true); return
        }
        let modal = PaymentModalViewController()
        modal.movieTitle   = movieTitle
        modal.movieDate    = movieDate
        modal.seatLocation = selectedSeats.map { $0.label }.joined(separator: ", ")
        modal.headCount    = headCount
        modal.ticketCounts = ticketCounts
        modal.totalPrice   = totalPrice
        modal.posterImage  = posterImage
        modal.modalPresentationStyle = .pageSheet
        if let sheet = modal.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        present(modal, animated: true)
    }
}

// MARK: - UIScrollViewDelegate (핀치 줌)
extension SeatSelectionViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { mainView.seatMapView }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let ox = max((scrollView.bounds.width  - scrollView.contentSize.width)  / 2, 0)
        let oy = max((scrollView.bounds.height - scrollView.contentSize.height) / 2, 0)
        mainView.seatMapView.center = CGPoint(
            x: scrollView.contentSize.width  / 2 + ox,
            y: scrollView.contentSize.height / 2 + oy
        )
    }
}

// MARK: - 결제 확인 모달
final class PaymentModalViewController: UIViewController {

    var movieTitle:   String = ""
    var movieDate:    String = ""
    var seatLocation: String = ""
    var headCount:    Int    = 0
    var ticketCounts: [TicketType: Int] = [:]
    var totalPrice:   Int    = 0
    var posterImage:  UIImage? = nil

    private let scrollView  = UIScrollView()
    private let contentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        buildUI()
    }

    private func buildUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.snp.makeConstraints { $0.edges.equalToSuperview(); $0.width.equalToSuperview() }

        let titleLabel = UILabel().then {
            $0.text = "예매 확인"; $0.font = .systemFont(ofSize: 22, weight: .bold); $0.textAlignment = .center
        }
        let posterView = UIImageView().then {
            $0.image = posterImage; $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true; $0.backgroundColor = .systemGray5
            $0.layer.cornerRadius = 10
        }
        let divider = UIView().then { $0.backgroundColor = .systemGray5 }

        let rows: [(String, String)] = [
            ("영화",       movieTitle),
            ("날짜 / 시간", movieDate),
            ("좌석",       seatLocation),
            ("인원",       "\(headCount)명"),
            ("총 금액",    formatPrice(totalPrice))
        ]
        let infoStack = UIStackView().then { $0.axis = .vertical; $0.spacing = 16 }
        rows.forEach { infoStack.addArrangedSubview(makeRow($0.0, $0.1, bold: $0.0 == "총 금액")) }

        let payBtn = UIButton().then {
            $0.setTitle("결제하기", for: .normal); $0.setTitleColor(.white, for: .normal)
            $0.backgroundColor = UIColor(red: 0.93, green: 0.11, blue: 0.14, alpha: 1)
            $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
            $0.layer.cornerRadius = 12
        }
        payBtn.addTarget(self, action: #selector(pay), for: .touchUpInside)

        [titleLabel, posterView, divider, infoStack, payBtn].forEach { contentView.addSubview($0) }

        titleLabel.snp.makeConstraints { $0.top.equalToSuperview().inset(28); $0.centerX.equalToSuperview() }
        posterView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview(); $0.width.equalTo(120); $0.height.equalTo(170)
        }
        divider.snp.makeConstraints {
            $0.top.equalTo(posterView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20); $0.height.equalTo(1)
        }
        infoStack.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        payBtn.snp.makeConstraints {
            $0.top.equalTo(infoStack.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(54); $0.bottom.equalToSuperview().inset(40)
        }
    }

    private func makeRow(_ key: String, _ val: String, bold: Bool) -> UIView {
        let c = UIView()
        let k = UILabel().then {
            $0.text = key
            $0.font = bold ? .systemFont(ofSize: 16, weight: .bold) : .systemFont(ofSize: 15)
            $0.textColor = .darkGray
        }
        let v = UILabel().then {
            $0.text = val
            $0.font = bold ? .systemFont(ofSize: 16, weight: .bold) : .systemFont(ofSize: 15)
            $0.textAlignment = .right; $0.numberOfLines = 0
            $0.textColor = bold ? UIColor(red: 0.93, green: 0.11, blue: 0.14, alpha: 1) : .black
        }
        [k, v].forEach { c.addSubview($0) }
        k.snp.makeConstraints { $0.leading.centerY.equalToSuperview() }
        v.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(k.snp.trailing).offset(12)
        }
        c.snp.makeConstraints { $0.height.greaterThanOrEqualTo(24) }
        return c
    }

    private func formatPrice(_ p: Int) -> String {
        let f = NumberFormatter(); f.numberStyle = .decimal
        return "\(f.string(from: NSNumber(value: p)) ?? "")원"
    }

    // MARK: - 결제 처리 → ReservationStore 저장 → 마이페이지로 이동
    @objc private func pay() {
        // 1. 저장
        let reservation = SavedReservation(
            id:           UUID().uuidString,
            movieTitle:   movieTitle,
            posterData:   posterImage?.pngData(),
            date:         String(movieDate.prefix(10)),
            time:         movieDate.count > 13 ? String(movieDate.dropFirst(13)) : "",
            seatLocation: seatLocation,
            headCount:    headCount,
            ticketTypes:  "\(headCount)명",
            totalPrice:   totalPrice,
            isCancelled:  false
        )
        ReservationStore.shared.save(reservation)

        // 2. 완료 알림 → 확인 누르면 마이페이지(탭 인덱스 2) 이동
        let alert = UIAlertController(
            title: "✅ 결제 완료",
            message: "예매가 완료되었습니다!\n마이페이지에서 확인하세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigateToMyPage()
        })
        present(alert, animated: true)
    }

    // MARK: - 마이페이지로 안전하게 이동
    private func navigateToMyPage() {
        guard let window = view.window else { return }

        // 루트까지 올라가면서 TabBarController 찾기
        func findTabBar(from vc: UIViewController?) -> UITabBarController? {
            guard let vc = vc else { return nil }
            if let tab = vc as? UITabBarController { return tab }
            return findTabBar(from: vc.presentingViewController ?? vc.parent)
        }

        // 모달 전체 닫기 후 마이페이지 탭 선택
        let rootVC = window.rootViewController
        rootVC?.dismiss(animated: true) {
            if let tab = findTabBar(from: rootVC) {
                tab.selectedIndex = 2
                // NavController 루트로
                if let nav = tab.viewControllers?[2] as? UINavigationController {
                    nav.popToRootViewController(animated: false)
                }
                // MyPageViewController 새로고침
                let myPageVC: MyPageViewController?
                if let nav = tab.viewControllers?[2] as? UINavigationController {
                    myPageVC = nav.viewControllers.first as? MyPageViewController
                } else {
                    myPageVC = tab.viewControllers?[2] as? MyPageViewController
                }
                myPageVC?.reloadReservations()
            }
        }
    }
}
