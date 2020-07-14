//
//  AccountViewModel.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/09.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import RxSwift
import RxCocoa

final class AccountViewModel: ViewModelType {
    struct Input {
        let fetchAccounts: Driver<Void>
        let logoutTaps: Signal<Void>
        let deleteUserTaps: Signal<Void>
    }

    struct Output {
        let accounts: Driver<[(Account, CAGradientLayer)]>
        let presentLogin: Signal<Void>
        let error: Signal<String>
    }

    private let disposeBag = DisposeBag()

    func transform(input: Input) -> Output {
        let presentLogin = PublishRelay<Void>()
        let error = PublishRelay<String>()
        let fetchAccountsResult = input.fetchAccounts.asObservable()
            .flatMap { Service.shared.fetchAccounts() }

        let accounts = fetchAccountsResult.map { result -> [(Account, CAGradientLayer)] in
            switch result {
            case .success(let accounts):
                var result = [(Account, CAGradientLayer)]()
                for (i, account) in accounts.enumerated() {
                    result.append((account, Gradient.make(i)))
                }
                return result
            case .noContent:
                break
            default:
                return [(Account(id: "0",
                                 bank: "카카오뱅크",
                                 alias: "테스트계좌",
                                 banlance: "30000",
                                 transactions: [.init(price: 2000, label: 3)]),
                         Gradient.make(1)), (Account(id: "1",
                                 bank: "농협",
                                 alias: "테스트어쩌구",
                                 banlance: "30000",
                                 transactions: [.init(price: 3000, label: 10), .init(price: 2000, label: 3)]),
                         Gradient.make(3)), (Account(id: "1",
                                 bank: "농협",
                                 alias: "테스트어쩌구",
                                 banlance: "30000",
                                 transactions: [.init(price: 3000, label: 10), .init(price: 2000, label: 3)]),
                         Gradient.make(3))]
                //                error.accept(ErrorMessage.plain)
            }
            return []
        }

        input.logoutTaps.asObservable()
            .flatMap { Service.shared.logout() }
            .bind { result in
                switch result {
                case .success: presentLogin.accept(())
                default: error.accept(ErrorMessage.plain)
                }
        }
        .disposed(by: disposeBag)

        input.deleteUserTaps.asObservable()
            .flatMap { Service.shared.deleteUser() }
            .bind { result in
                switch result {
                case .success: presentLogin.accept(())
                default: error.accept(ErrorMessage.plain)
                }
        }
        .disposed(by: disposeBag)

        return .init(accounts: accounts.asDriver(onErrorJustReturn: []),
                     presentLogin: presentLogin.asSignal(),
                     error: error.asSignal())
    }
}