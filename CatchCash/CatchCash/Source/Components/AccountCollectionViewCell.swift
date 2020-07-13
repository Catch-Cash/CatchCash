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
    var minusHeight: CGFloat = 0

    private var gradientLayer: CAGradientLayer? {
        return self.layer.sublayers?.first as? CAGradientLayer
    }
    
    private let disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 16
    }

    func setup(_ account: Account, _ layer: CAGradientLayer) {
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
}
