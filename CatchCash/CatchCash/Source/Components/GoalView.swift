//
//  GoalView.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/07.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

final class GoalView: UIView {

    // MARK: UI Properties when isOpen
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var goalPriceTextField: UITextField!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var currentPriceLabel: UILabel!
    @IBOutlet weak var circleChartContainerView: UIView!
    @IBOutlet weak var achievementRateInContainerLabel: UILabel!

    // MARK: UI Properties when isClose
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var achievementRateLabel: UILabel!

    var category: UsageCategory = .income
    lazy var heightConstraint = self.heightAnchor.constraint(equalToConstant: 40)

    var isOpened = false {
        didSet {
            heightConstraint.isActive = !isOpened

            titleLabel.isHidden = !isOpened
            editButton.isHidden = !isOpened
            goalLabel.isHidden = !isOpened
            goalPriceTextField.isHidden = !isOpened
            currentLabel.isHidden = !isOpened
            currentPriceLabel.isHidden = !isOpened
            circleChartContainerView.isHidden = !isOpened
            subTitleLabel.isHidden = isOpened
            achievementRateLabel.isHidden = isOpened

            gradientLayer?.isHidden = !isOpened
            view.backgroundColor = isOpened ? nil : category.color

            if isOpened { chartView.setNeedsDisplay() }
        }
    }
    var isEditingMode = false {
        didSet {
            if isEditingMode {
                (self.window?.rootViewController as? UITabBarController)?.viewControllers?
                    .first?.showToast(Message.goal)
            }
        }
    }

    private var gradientLayer: CAGradientLayer? {
        return view.layer.sublayers?.first as? CAGradientLayer
    }

    private var view = UIView()
    private let chartView = CircleChartView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commontInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commontInit()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        view.frame = self.bounds
        gradientLayer?.frame = self.bounds
    }

    func commontInit() {
        view = Bundle.main.loadNibNamed("GoalView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        chartView.frame = circleChartContainerView.bounds
        circleChartContainerView.addSubview(chartView)
    }

    func setup(_ category: UsageCategory) {
        self.category = category
        self.layer.cornerRadius = 12

        let layer = category.gradient
        layer.cornerRadius = 12
        view.layer.insertSublayer(layer, at: 0)
        view.layer.cornerRadius = 12

        isOpened = category == .income
        titleLabel.text = category.title
        subTitleLabel.text = category.title
        view.backgroundColor = category.color
    }

    func setup(_ goal: Goal) {
        goalPriceTextField.text = "\(goal.goal) 원"
        currentPriceLabel.text = "\(goal.current) 원"
        achievementRateLabel.text = "달성률 \(goal.achievementRate)%"
        chartView.percent = CGFloat(goal.achievementRate)
        achievementRateInContainerLabel.text = "\(goal.achievementRate)%"
        chartView.setNeedsDisplay()
    }
}

extension GoalView {
    
}
