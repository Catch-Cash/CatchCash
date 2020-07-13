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

    var didSetup = false

    func setup(_ transaction: SimpleTransaction) {
        self.layer.cornerRadius = 6
        labelLabel.text = Label(transaction.label).title
        priceLabel.text = "\(transaction.price) 원"
        didSetup = true
    }
}
