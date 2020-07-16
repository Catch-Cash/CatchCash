//
//  LabelPickerCollectionViewCell.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/16.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

final class LabelCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    func setup(_ label: Label) {
        titleLabel.text = label.title
        self.layer.cornerRadius = 15
        self.backgroundColor = label.color
    }
}
