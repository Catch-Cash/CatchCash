//
//  TransactionTableViewCellModel.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/16.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import RxSwift
import RxCocoa

final class TransactionTableViewCellModel: ViewModelType {
    struct Input {
        let info: Driver<Transaction>
    }

    struct Output {
        let result: Driver<Transaction?>
    }

    func transform(input: Input) -> Output {
        return .init(result: input.info.asObservable()
            .flatMap { Service.shared.updateTransaction($0) }
            .flatMap { $0 == .noContent ? input.info.map { $0 } : .just(nil) }
            .asDriver(onErrorJustReturn: nil))
    }
}
