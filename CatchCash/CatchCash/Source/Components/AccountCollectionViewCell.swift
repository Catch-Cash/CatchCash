//
//  AccountCollectionViewCell.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/07.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

final class AccountCollectionViewCell: UICollectionViewCell {

    struct Constant {
        static let openHeight: CGFloat = 235
        static let closeHeight: CGFloat = 110
    }

    @IBOutlet weak var bankLabel: UILabel!
    @IBOutlet weak var aliasLabel: UILabel!
    @IBOutlet weak var aliasTextField: UITextField!
    @IBOutlet weak var editingButton: UIButton!
    @IBOutlet weak var recentlyTransactionLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var balanceLabel: UILabel!

    var isOpened = false {
        didSet {
            editingButton.isHidden = !isOpened
            recentlyTransactionLabel.isHidden = !isOpened
            stackView.isHidden = !isOpened
            balanceLabel.textAlignment = isOpened ? .right : .left
            gradientLayer?.frame.size
                = .init(width: self.bounds.width,
                        height: isOpened ? Constant.openHeight - minusHeight : Constant.closeHeight)
        }
    }
    var isEditingMode = false {
        didSet {
            self.editingButton.isSelected = isEditingMode
            self.aliasLabel.isHidden = isEditingMode
            self.aliasTextField.isHidden = !isEditingMode
        }
    }
    var minusHeight: CGFloat = 0

    private var gradientLayer: CAGradientLayer? {
        return self.layer.sublayers?.first as? CAGradientLayer
    }
    private var id = ""

    private let viewModel = AccountCollectionViewModel()
    private let disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        aliasTextField.delegate = self
        self.layer.cornerRadius = 16

        editingButton.rx.tap
            .bind { [weak self] _ in
                self?.isEditingMode.toggle()
        }
        .disposed(by: disposeBag)
        
        bindViewModel()
    }

    func setup(_ account: Account, _ layer: CAGradientLayer) {
        id = account.id
        bankLabel.text = account.bank
        aliasLabel.text = account.alias
        let views = stackView.arrangedSubviews.compactMap { $0 as? SimpleTransactionView } 
        for i in 0..<account.transactions.count {
            views[i].setup(account.transactions[i], color: layer.colors?.first)
        }
        for view in views {
            if !view.didSetup {
                view.removeFromSuperview()
                minusHeight += 24
            }
        }
        layer.frame = self.bounds
        self.layer.insertSublayer(layer, at: 0)
    }

    private func bindViewModel() {
        let input = AccountCollectionViewModel.Input(
            info: aliasTextField.rx.text.orEmpty
                .distinctUntilChanged()
                .filter { [weak self] in self?.aliasLabel.text != $0 }
                .map { [weak self] in
                    guard let self = self else { return ("","") }
                    return (self.id, $0)
                }
                .asDriver(onErrorJustReturn: ("",""))
        )

        let output = viewModel.transform(input: input)

        output.result.drive(aliasLabel.rx.text).disposed(by: disposeBag)
    }
}

extension AccountCollectionViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        aliasTextField.resignFirstResponder()
    }
}
