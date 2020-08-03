//
//  GoalViewViewModel.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/20.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import RxSwift
import RxCocoa

final class GoalViewViewModel: ViewModelType {
    struct Input {
        let updateGoals: Driver<(category: UsageCategory, goal: Int)>
    }

    struct Output {
        let goal: Driver<Goal?>
    }

    private let disposeBag = DisposeBag()

    func transform(input: Input) -> Output {
        return .init(goal: input.updateGoals.asObservable()
            .flatMap { Service.shared.updateGoal($0.category, goal: $0.goal) }
            .map { result in
                switch result {
                case .success(let goal): return goal
                default: return nil
                }
            }
            .asDriver(onErrorJustReturn: nil)
        )
    }
}
