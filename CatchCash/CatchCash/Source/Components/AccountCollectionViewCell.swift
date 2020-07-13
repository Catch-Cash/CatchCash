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

    @IBOutlet weak var bankLabel: UILabel!
    @IBOutlet weak var aliasLabel: UILabel!
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
        }
    }
    var minusHeight: CGFloat = 0
    
    private let disposeBag = DisposeBag()
    private var backgroundLayer = CAGradientLayer()

    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.insertSublayer(backgroundLayer, at: 0)
        self.layer.cornerRadius = 16
    }

    func setup(_ account: Account, _ layer: CAGradientLayer) {
        bankLabel.text = account.bank
        aliasLabel.text = account.alias
        let views = stackView.arrangedSubviews.compactMap { $0 as? SimpleTransactionView } 
        for i in 0..<account.transactions.count {
            views[i].setup(account.transactions[i])
        }
        for view in views {
            if !view.didSetup {
                view.removeFromSuperview()
                minusHeight += 24
            }
        }
    }
}
