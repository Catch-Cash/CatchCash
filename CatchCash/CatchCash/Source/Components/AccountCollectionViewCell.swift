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
            if isEditingMode {
                (self.window?.rootViewController as? UITabBarController)?.viewControllers?
                    .first?.showToast(Message.text)
            }
        }
    }
    var minusHeight: CGFloat = 0

    private var gradientLayer: CAGradientLayer? {
        return self.layer.sublayers?.first as? CAGradientLayer
    }
    private var id = ""
    private var defaultAlias = ""

    private let viewModel = AccountCollectionViewCellViewModel()
    private let disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        aliasTextField.delegate = self
        self.layer.cornerRadius = 16

        editingButton.rx.tap
            .bind { [weak self] _ in
                if self?.isEditingMode == true { self?.aliasTextField.resignFirstResponder() }
                self?.isEditingMode.toggle()
            }
            .disposed(by: disposeBag)
        
        bindViewModel()
    }

    func setup(_ account: Account, _ layer: CAGradientLayer) {
        id = account.id
        defaultAlias = account.alias

        bankLabel.text = account.bank
        aliasLabel.text = account.alias
        balanceLabel.text = "\(account.banlance) 원"

        let views = stackView.arrangedSubviews.compactMap { $0 as? SimpleTransactionView }
        minusHeight = 0

        for i in 0..<account.transactions.count {
            if views.count <= i {
                stackView.addArrangedSubview(SimpleTransactionView())
            }
            views[i].setup(account.transactions[i], color: layer.colors?.first)
            views[i].isHidden = false
        }
        for view in views {
            if !view.didSetup {
                view.isHidden = true
                minusHeight += 24
            }
        }
        layer.frame = self.bounds
        self.layer.insertSublayer(layer, at: 0)
    }

    private func bindViewModel() {
        let info = aliasTextField.rx.text.orEmpty
            .distinctUntilChanged()
            .filter { [weak self] in self?.aliasLabel.text != $0 }
            .map { [weak self] text -> (id: String, String) in
                guard let self = self else { return ("", "") }
                return (self.id, text)
            }

        let input = AccountCollectionViewCellViewModel.Input(
            info: editingButton.rx.tap
                .filter { [weak self] in self?.isEditingMode == false }
                .withLatestFrom(info)
                .asDriver(onErrorJustReturn: ("", ""))
        )

        let output = viewModel.transform(input: input)

        output.result
            .filter { [weak self] result in
                if result == nil { self?.aliasLabel.text = self?.aliasTextField.text }
                return result != nil
            }
            .drive(onNext: { [weak self] _ in
                self?.aliasLabel.text = self?.defaultAlias
                self?.aliasTextField.text = self?.defaultAlias
            })
            .disposed(by: disposeBag)
    }
}

extension AccountCollectionViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
