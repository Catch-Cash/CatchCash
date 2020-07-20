//
//  GoalViewModel.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/19.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import RxSwift
import RxCocoa

final class GoalViewModel: ViewModelType {
    struct Input {
        let fetchGoals: Driver<Void>
    }

    struct Output {
        let goals: Driver<GoalResponse?>
    }

    private let disposeBag = DisposeBag()

    func transform(input: Input) -> Output {
        return .init(goals: input.fetchGoals.asObservable()
            .flatMap { Service.shared.fetchGoals() }
            .map { result in
                switch result {
                case .success(let goals): return goals
                default: return .init(income: .init(goal: 3000000, current: 200000, achievementRate: 66),
                                      expense: .init(goal: 1000000, current: 500000, achievementRate: 50),
                                      saving: .init(goal: 1000000, current: 300000, achievementRate: 33))
                }
            }.asDriver(onErrorJustReturn: nil)
        )
    }
}
