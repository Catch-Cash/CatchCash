//
//  GoalView.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/07.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

@IBDesignable
class GoalView: UIView {

    // MARK: UI Properties when isOpen
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var goalPriceLabel: UILabel!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var currentPriceLabel: UILabel!
    @IBOutlet weak var pieChartView: PieChartView!

    // MARK: UI Properties when isClose
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var achievementRateLabel: UILabel!
}
