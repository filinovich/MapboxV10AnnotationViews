//
//  PinView.swift
//  MAPBOXV10
//
//  Created by Ilya Filinovich on 28.07.2022.
//

import CoreLocation
import Foundation
import UIKit

final class PinView: UIView {

    let id: Int

    private let label = UILabel()
    private let leftLabel = UILabel()
    private let rightLabel = UILabel()
    private let upLabel = UILabel()
    private let downLabel = UILabel()

    var showUp = true {
        didSet {
            if showUp != oldValue {
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.1, delay: 0) {
                    self.upLabel.isHidden = !self.showUp
                }
            }
        }
    }
    var showleft = true {
        didSet {
            if showleft != oldValue {
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.1, delay: 0) {
                    self.leftLabel.isHidden = !self.showleft
                }
            }
        }
    }
    var showDown = true {
        didSet {
            if showDown != oldValue {
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.1, delay: 0) {
                    self.downLabel.isHidden = !self.showDown
                }
            }
        }
    }
    var showRight = true {
        didSet {
            if showRight != oldValue {
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.1, delay: 0) {
                    self.rightLabel.isHidden = !self.showRight
                }
            }
        }
    }

    required init(id: Int, text: String) {
        self.id = id
        label.text = text
        super.init(frame: .zero)

        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        backgroundColor = .white
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 10

        leftLabel.text = "👈"
        rightLabel.text = "👉"
        upLabel.text = "☝️"
        downLabel.text = "👇"

        let hsv = UIStackView(arrangedSubviews: [leftLabel, label, rightLabel])
        hsv.axis = .horizontal
        hsv.alignment = .center
        let vsv = UIStackView(arrangedSubviews: [upLabel, hsv, downLabel])
        vsv.axis = .vertical
        vsv.alignment = .center

        [hsv, vsv, leftLabel, upLabel, rightLabel, downLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        addSubview(vsv)

        NSLayoutConstraint.activate([
            vsv.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            vsv.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            vsv.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            vsv.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
    }
}
