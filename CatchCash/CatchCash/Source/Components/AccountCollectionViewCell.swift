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
    @IBOutlet weak var editingButton: UIButton!
    @IBOutlet weak var recentlyTransactionLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var balanceLabel: UILabel!

    var isClosed = PublishSubject<Bool>()

    private let disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bindIsClosed()
    }

    func setup(_ account: Account, _ layer: CAGradientLayer) {
        bankLabel.text = account.bank
        aliasLabel.text = account.alias
        let views = stackView.arrangedSubviews.compactMap { $0 as? SimpleTransactionView }
        for i in 0..<account.transactions.count {
            views[i].setup(account.transactions[i])
        }
    }

    private func bindIsClosed() {
        isClosed.bind(to: editingButton.rx.isHidden).disposed(by: disposeBag)
        isClosed.bind(to: recentlyTransactionLabel.rx.isHidden).disposed(by: disposeBag)
        isClosed.bind(to: stackView.rx.isHidden).disposed(by: disposeBag)
        isClosed.bind { [weak self] isClosed in
            if isClosed {
                self?.heightAnchor.constraint(equalToConstant: Constant.closeHeight).isActive = true
            } else {
                self?.heightAnchor.constraint(equalToConstant: Constant.openHeight).isActive = true
            }
        }
        .disposed(by: disposeBag)
    }
}
