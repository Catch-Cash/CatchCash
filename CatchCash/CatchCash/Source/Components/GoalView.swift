//
//  GoalView.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/07.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

final class GoalView: UIView {

    // MARK: UI Properties when isOpen
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var editingButton: UIButton!
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
            editingButton.isHidden = !isOpened
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
            goalPriceTextField.isEnabled = isEditingMode
            editingButton.isSelected = isEditingMode

            if isEditingMode {
                (self.window?.rootViewController as? UITabBarController)?.viewControllers?[2].showToast(Message.goal)
            }
        }
    }

    private var gradientLayer: CAGradientLayer? {
        return view.layer.sublayers?.first as? CAGradientLayer
    }
    private var defaultGoal: Goal?
    private var view = UIView()

    private let chartView = CircleChartView()
    private let disposeBag = DisposeBag()
    private let viewModel = GoalViewViewModel()

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

        editingButton.rx.tap
            .bind { [weak self] _ in
                if self?.isEditingMode == true { self?.dismissKeyboard() }
                self?.isEditingMode.toggle()
            }
            .disposed(by: disposeBag)

        goalPriceTextField.delegate = self
        bindViewModel()
        setupToolBar()
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
        self.defaultGoal = goal
        goalPriceTextField.text = "\(goal.goal) 원"
        currentPriceLabel.text = "\(goal.current) 원"
        achievementRateLabel.text = "달성률 \(goal.achievementRate)%"
        chartView.percent = CGFloat(goal.achievementRate)
        achievementRateInContainerLabel.text = "\(goal.achievementRate)%"
        chartView.setNeedsDisplay()
    }

    private func bindViewModel() {
        let input = GoalViewViewModel.Input(
            updateGoals: editingButton.rx.tap
                .filter { [weak self] _ in self?.isEditingMode == false }
                .withLatestFrom(goalPriceTextField.rx.text.orEmpty)
                { [weak self] _, text in (self?.category ?? .income, Int(text) ?? 0) }
                .asDriver(onErrorJustReturn: (.income, 0))
        )
        let output = viewModel.transform(input: input)

        output.goal.compactMap { $0 }
            .drive(onNext: { [weak self] goal in
                self?.defaultGoal = goal
                self?.setup(goal)
            })
            .disposed(by: disposeBag)

        output.goal.filter { $0 == nil }
            .drive(onNext: { [weak self] _ in
                self?.goalPriceTextField.text = "\(self?.defaultGoal?.goal ?? 0) 원"
            })
            .disposed(by: disposeBag)
    }

    private func setupToolBar() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let barButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        toolBar.items = [barButton]
        toolBar.tintColor = #colorLiteral(red: 1, green: 0.5531694889, blue: 0.3933998346, alpha: 1)

        goalPriceTextField.inputAccessoryView = toolBar
    }

    @objc private func dismissKeyboard() {
        goalPriceTextField.resignFirstResponder()
    }
}

extension GoalView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
