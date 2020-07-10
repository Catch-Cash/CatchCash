//
//  ToastView.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/10.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

final class ToastView: UIView {

    private let label = UILabel()
    private var didSetupConstraints = false

    init(_ message: String) {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.layer.cornerRadius = 12
        self.alpha = 1
        self.translatesAutoresizingMaskIntoConstraints = false

        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = message
        self.addSubview(label)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didAddSubview(_ subview: UIView) {
        UIView.animate(withDuration: 3,
                       delay: 1,
                       options: .curveEaseOut,
                       animations: { self.alpha = 0 }) { _ in self.removeFromSuperview() }
    }

    override func updateConstraints() {
        if !didSetupConstraints {
            guard let safeArea = self.superview?.safeAreaLayoutGuide else { return }
            self.heightAnchor.constraint(equalToConstant: 50).isActive = true
            self.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -48).isActive = true
            self.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16).isActive = true
            self.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16).isActive = true

            label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            didSetupConstraints = true
        }
        super.updateConstraints()
    }
}
