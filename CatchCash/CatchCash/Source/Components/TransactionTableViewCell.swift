//
//  TransactionHistoryTableViewCell.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/07.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

final class TransactionTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var labelLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var editingButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var priceLabel: UILabel!

    var isOpened = false {
        didSet {
            editingButton.isHidden = !isOpened
            descriptionTextView.isHidden = !isOpened
        }
    }
//    var isEditingMode = false {
//        didSet {
//            self.editingButton.isSelected = isEditingMode
//            self.aliasLabel.isHidden = isEditingMode
//            self.aliasTextField.isHidden = !isEditingMode
//        }
//    }

    override func awakeFromNib() {
        super.awakeFromNib()
        labelLabel.clipsToBounds = true
        labelLabel.layer.cornerRadius = labelLabel.bounds.height / 2
        containerView.layer.cornerRadius = 8
        self.backgroundColor = nil
    }

    func setup(_ transaction: Transaction) {
        let label = Label(transaction.label)
        labelLabel.text = label.title
        labelLabel.backgroundColor = label.color
        accountLabel.text = transaction.account
        titleTextField.text = transaction.title
        descriptionTextView.text = transaction.description
        priceLabel.text = (label == .income ? "+" : "-") + "\(transaction.price ?? 0) 원"
        priceLabel.textColor = label == .income ? Color.transactionIncome : Color.transactionExpense
    }
    
}
