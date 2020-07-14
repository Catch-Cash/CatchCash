//
//  AccountCollectionViewModel.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/14.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import RxSwift
import RxCocoa

final class AccountCollectionViewModel: ViewModelType {
    struct Input {
        let info: Driver<(id: String, String)>
    }

    struct Output {
        let result: Driver<String>
    }

    private let disposeBag = DisposeBag()

    func transform(input: Input) -> Output {
        return .init(result: input.info.asObservable()
            .flatMap { Service.shared.updateAccount($0.0, alias: $0.1) }
            .filter { $0 == .noContent }
            .withLatestFrom(input.info.map { $0.1 })
            .asDriver(onErrorJustReturn: ""))
    }
}
