//
//  GoalViewController.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/17.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

final class GoalViewController: UIViewController {

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var goalStackView: UIStackView!

    private let goalViews: [GoalView] = [.init(), .init(), .init()]
    private let disposeBag = DisposeBag()
    private let viewModel = GoalViewModel()
    private let fetchGoals = BehaviorRelay<Void>(value: ())

    var selectedCategory: UsageCategory = .income {
        didSet {
            goalViews[oldValue.rawValue].isOpened = false
            goalViews[selectedCategory.rawValue].isOpened = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        for (i, view) in goalViews.enumerated() {
            view.setup(UsageCategory(rawValue: i) ?? .income)
            let gesture = UITapGestureRecognizer(target: self, action: #selector(openGoalView))
            view.addGestureRecognizer(gesture)
            goalStackView.addArrangedSubview(view)
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M월의 목표"
        monthLabel.text = dateFormatter.string(from: .init())

        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchGoals.accept(())
    }

    private func bindViewModel() {
        let input = GoalViewModel.Input(fetchGoals: fetchGoals.asDriver())
        let output = viewModel.transform(input: input)

        output.goals.compactMap { $0 }
            .drive(onNext: { [weak self] response in
                self?.goalViews[0].setup(response.income)
                self?.goalViews[1].setup(response.expense)
                self?.goalViews[2].setup(response.saving)
            })
            .disposed(by: disposeBag)
    }

    @objc private func openGoalView(_ recognizer: UITapGestureRecognizer) {
        guard let view = recognizer.view as? GoalView else { return }
        if selectedCategory == view.category { return }
        selectedCategory = view.category
    }
}
