//
//  AccountCollectionViewModel.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/14.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import RxSwift
import RxCocoa

final class AccountCollectionViewCellModel: ViewModelType {
    struct Input {
        let info: Driver<(id: String, String)>
    }

    struct Output {
        let result: Driver<String?>
    }

    func transform(input: Input) -> Output {
        return .init(result: input.info.asObservable()
            .flatMap { Service.shared.updateAccount($0.0, alias: $0.1) }
            .map { $0 == .noContent ? nil : "오류가 발생했습니다" }
            .asDriver(onErrorJustReturn: nil))
    }
}
