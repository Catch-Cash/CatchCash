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
        let isLoading: Signal<Bool>
    }

    private let disposeBag = DisposeBag()

    func transform(input: Input) -> Output {
        let isLoading = PublishRelay<Bool>()

        return .init(
            goals: input.fetchGoals.asObservable()
                .do(onNext: { isLoading.accept(true) })
                .flatMap { Service.shared.fetchGoals() }
                .map { result in
                    defer { isLoading.accept(false) }
                    switch result {
                    case .success(let goals): return goals
                    default: return nil
                    }
                }
                .asDriver(onErrorJustReturn: nil),
            isLoading: isLoading.asSignal()
        )
    }
}
