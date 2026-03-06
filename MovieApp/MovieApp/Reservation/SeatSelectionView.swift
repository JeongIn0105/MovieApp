//
//  SeatSelectionView.swift
//  MovieApp
//

import UIKit
import SnapKit
import Then

// MARK: - 좌석 데이터
struct Seat {
    let row: String
    let col: Int
    var isOccupied: Bool
    var isSelected: Bool
    var label: String { "\(row)\(col)" }
}

// MARK: - 좌석 배치도 Custom Drawing View
final class SeatMapView: UIView {

    private let seatSize:      CGFloat = 36
    private let seatSpacing:   CGFloat = 8
    private let aisleWidth:    CGFloat = 20
    private let rowLabelWidth: CGFloat = 24
    private let leftCols  = 6
    private let rightCols = 6
    private let rows = ["A","B","C","D","E","F","G","H"]

    var seats: [[Seat]] = []
    var onSeatTapped: ((IndexPath) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.13, alpha: 1.0)
        setupSeats()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(_:))))
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupSeats() {
        let occupied: Set<String> = []
        seats = rows.map { row in
            (1...(leftCols + rightCols)).map { col in
                Seat(row: row, col: col,
                     isOccupied: occupied.contains("\(row)\(col)"),
                     isSelected: false)
            }
        }
    }

    @objc private func tapped(_ g: UITapGestureRecognizer) {
        let p = g.location(in: self)
        let topPad: CGFloat = 60
        let step = seatSize + seatSpacing
        for (ri, rowSeats) in seats.enumerated() {
            let y = topPad + CGFloat(ri) * step
            guard p.y >= y && p.y < y + seatSize else { continue }
            for (ci, _) in rowSeats.enumerated() {
                let x = seatX(ci)
                guard p.x >= x && p.x < x + seatSize else { continue }
                onSeatTapped?(IndexPath(item: ci, section: ri)); return
            }
        }
    }

    private func seatX(_ col: Int) -> CGFloat {
        let step = seatSize + seatSpacing
        let start = rowLabelWidth + 8
        if col < leftCols { return start + CGFloat(col) * step }
        return start + CGFloat(leftCols) * step + aisleWidth + CGFloat(col - leftCols) * step
    }

    override var intrinsicContentSize: CGSize {
        let step = seatSize + seatSpacing
        let w = rowLabelWidth + 8 + CGFloat(leftCols)*step + aisleWidth + CGFloat(rightCols)*step + 16
        let h: CGFloat = 60 + CGFloat(rows.count) * step + 40
        return CGSize(width: max(w, 320), height: h)
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        drawScreen(ctx)
        drawLabels(ctx)
        drawSeats(ctx)
    }

    private func drawScreen(_ ctx: CGContext) {
        let w = intrinsicContentSize.width - 40
        let r = CGRect(x: 20, y: 16, width: w, height: 14)
        ctx.setFillColor(UIColor(white: 0.55, alpha: 1).cgColor)
        ctx.fill(r)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold),
            .foregroundColor: UIColor(white: 0.85, alpha: 1)
        ]
        let s = NSAttributedString(string: "SCREEN", attributes: attrs)
        let sz = s.size()
        s.draw(at: CGPoint(x: 20 + (w - sz.width) / 2, y: 16 + (14 - sz.height) / 2))
    }

    private func drawLabels(_ ctx: CGContext) {
        let step = seatSize + seatSpacing
        for (i, row) in rows.enumerated() {
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
                .foregroundColor: UIColor(white: 0.65, alpha: 1)
            ]
            let s = NSAttributedString(string: row, attributes: attrs)
            s.draw(at: CGPoint(x: 4, y: 60 + CGFloat(i) * step + (seatSize - s.size().height) / 2))
        }
    }

    private func drawSeats(_ ctx: CGContext) {
        let step = seatSize + seatSpacing
        for (ri, rowSeats) in seats.enumerated() {
            let y = 60 + CGFloat(ri) * step
            for (ci, seat) in rowSeats.enumerated() {
                let x = seatX(ci)
                let sr = CGRect(x: x, y: y, width: seatSize, height: seatSize)

                // ── 색상 결정 ──
                let color: UIColor
                if seat.isSelected {
                    color = UIColor(red: 0.93, green: 0.11, blue: 0.14, alpha: 1)  // 선택: 빨강
                } else if seat.isOccupied {
                    color = UIColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 1)  // 예매완료: 짙은 회색
                } else {
                    color = UIColor(white: 0.72, alpha: 1)                          // 빈 좌석: 밝은 회색
                }

                // ── 배경 그리기 ──
                ctx.setFillColor(color.cgColor)
                ctx.addPath(UIBezierPath(roundedRect: sr, cornerRadius: 6).cgPath)
                ctx.fillPath()

                // ── 예매완료: 체크마크 + "예매" 텍스트 ──
                if seat.isOccupied {
                    // 체크마크 (✓)
                    let checkAttrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 14, weight: .bold),
                        .foregroundColor: UIColor(white: 0.55, alpha: 1)
                    ]
                    let check = NSAttributedString(string: "✓", attributes: checkAttrs)
                    let csz = check.size()
                    check.draw(at: CGPoint(
                        x: x + (seatSize - csz.width) / 2,
                        y: y + 4
                    ))
                    // "예매" 텍스트
                    let textAttrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 8, weight: .medium),
                        .foregroundColor: UIColor(white: 0.50, alpha: 1)
                    ]
                    let label = NSAttributedString(string: "예매", attributes: textAttrs)
                    let lsz = label.size()
                    label.draw(at: CGPoint(
                        x: x + (seatSize - lsz.width) / 2,
                        y: y + seatSize - lsz.height - 4
                    ))
                }

                // ── 선택됨: 좌석 번호 표시 ──
                if seat.isSelected {
                    let attrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 10, weight: .bold),
                        .foregroundColor: UIColor.white
                    ]
                    let s = NSAttributedString(string: seat.label, attributes: attrs)
                    let sz = s.size()
                    s.draw(at: CGPoint(
                        x: x + (seatSize - sz.width) / 2,
                        y: y + (seatSize - sz.height) / 2
                    ))
                }
            }
        }
    }
}

// MARK: - 전체 좌석 선택 화면 뷰
final class SeatSelectionView: UIView {

    // ── ScrollView (핀치줌 + 드래그) ──
    let scrollView = UIScrollView().then {
        $0.backgroundColor = UIColor(white: 0.13, alpha: 1.0)
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator   = false
        $0.bouncesZoom      = true
        $0.minimumZoomScale = 0.7
        $0.maximumZoomScale = 2.5
        $0.decelerationRate = .fast
    }
    let seatMapView = SeatMapView()

    // ── 범례 바 (topBar/X버튼 제거됨) ──
    private let legendBar = UIView().then {
        $0.backgroundColor = UIColor(white: 0.10, alpha: 1.0)
    }

    // ── 하단 바 ──
    let bottomBar          = UIView().then { $0.backgroundColor = UIColor(white: 0.10, alpha: 1.0) }
    let selectedCountLabel = UILabel().then {
        $0.text = "선택 0석"
        $0.textColor = UIColor(white: 0.75, alpha: 1)
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
    }
    let selectedSeatsLabel = UILabel().then {
        $0.text = "좌석을 선택해 주세요"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 16, weight: .bold)
    }
    let confirmButton = UIButton().then {
        $0.setTitle("선택 완료", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor(white: 0.35, alpha: 1.0)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        $0.layer.cornerRadius = 10
        $0.isEnabled = false
    }

    // ── 닫기 버튼 (SeatSelectionViewController에서 addTarget) ──
    let closeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        $0.tintColor = .white
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.13, alpha: 1.0)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        // topBar 없이: 범례 + 뒤로가기 버튼만 상단에 배치
        [legendBar, scrollView, bottomBar].forEach { addSubview($0) }
        scrollView.addSubview(seatMapView)

        // 범례 스택
        let legendStack = UIStackView().then {
            $0.axis = .horizontal; $0.spacing = 20
            $0.alignment = .center; $0.distribution = .fillEqually
        }
        legendStack.addArrangedSubview(legendItem(UIColor(white: 0.72, alpha: 1), "빈 좌석"))
        legendStack.addArrangedSubview(legendItem(UIColor(red: 0.93, green: 0.11, blue: 0.14, alpha: 1), "선택"))
        legendStack.addArrangedSubview(legendItem(UIColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 1), "예매완료"))
        legendBar.addSubview(legendStack)
        legendBar.addSubview(closeButton)

        [selectedCountLabel, selectedSeatsLabel, confirmButton].forEach { bottomBar.addSubview($0) }

        // ── Constraints ──
        legendBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }
        closeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(32)
        }
        legendStack.snp.makeConstraints {
            $0.leading.equalTo(closeButton.snp.trailing).offset(4)
            $0.trailing.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview()
        }
        scrollView.snp.makeConstraints {
            $0.top.equalTo(legendBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomBar.snp.top)
        }

        let ms = seatMapView.intrinsicContentSize
        seatMapView.frame = CGRect(origin: .zero, size: ms)
        scrollView.contentSize = ms

        bottomBar.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(110)
        }
        selectedCountLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(14)
            $0.leading.equalToSuperview().inset(20)
        }
        selectedSeatsLabel.snp.makeConstraints {
            $0.top.equalTo(selectedCountLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalTo(confirmButton.snp.leading).offset(-8)
        }
        confirmButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(110)
            $0.height.equalTo(46)
        }
    }

    private func legendItem(_ color: UIColor, _ text: String) -> UIView {
        let c   = UIView()
        let box = UIView().then { $0.backgroundColor = color; $0.layer.cornerRadius = 4 }
        let lbl = UILabel().then {
            $0.text = text
            $0.textColor = UIColor(white: 0.80, alpha: 1)
            $0.font = .systemFont(ofSize: 11)
        }
        [box, lbl].forEach { c.addSubview($0) }
        box.snp.makeConstraints { $0.leading.centerY.equalToSuperview(); $0.width.height.equalTo(12) }
        lbl.snp.makeConstraints { $0.leading.equalTo(box.snp.trailing).offset(5); $0.centerY.equalToSuperview() }
        return c
    }

    func updateSelectionUI(selectedSeats: [Seat], maxCount: Int) {
        let n = selectedSeats.count
        selectedCountLabel.text = "선택 \(n)/\(maxCount)석"
        if selectedSeats.isEmpty {
            selectedSeatsLabel.text = "좌석을 선택해 주세요"
            confirmButton.isEnabled = false
            confirmButton.backgroundColor = UIColor(white: 0.35, alpha: 1)
        } else {
            selectedSeatsLabel.text = selectedSeats.map { $0.label }.joined(separator: ", ")
            let done = (n == maxCount)
            confirmButton.isEnabled = done
            confirmButton.backgroundColor = done
                ? UIColor(red: 0.93, green: 0.11, blue: 0.14, alpha: 1)
                : UIColor(white: 0.35, alpha: 1)
        }
        seatMapView.setNeedsDisplay()
    }
}
