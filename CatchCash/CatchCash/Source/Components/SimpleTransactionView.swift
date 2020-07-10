//
//  SimpleTransactionView.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/09.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

final class SimpleTransactionView: UIView {
    @IBOutlet weak var labelLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    func setup(_ transaction: SimpleTransaction) {
        labelLabel.text = Label(transaction.label).title
        priceLabel.text = "\(transaction.price) 원"
    }
}
