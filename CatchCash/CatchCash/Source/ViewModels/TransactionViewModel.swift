//
//  TransactionViewModel.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/14.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import RxSwift
import RxCocoa

final class TransactionViewModel: ViewModelType {
    struct Input {
        let fetchTransactions: Driver<SimpleAccount?>
        let loadTransactions: Signal<Void>
    }

    struct Output {
        let transactions: Driver<[TransactionSectionModel]>
        let error: Signal<String>
    }

    private let isNextPageExists = BehaviorRelay<Bool>(value: false)
    private var page = 1
    private let disposeBag = DisposeBag()

    func transform(input: Input) -> Output {
        let error = PublishRelay<String>()
        let fetchTransactions = input.fetchTransactions.asObservable()
            .flatMap { Service.shared.fetchTransactions($0?.id) }
            .map { [weak self] result -> [Transaction] in
                switch result {
                case .success(let response):
                    self?.updatePage(response.isNextPageExists == "Y")
                    return response.transactions
                case .noContent:
                    break
                default:
                    error.accept(ErrorMessage.plain)
                }
                return [.init(id: 0, label: 1, title: "브로콜리 샐러드", description: "오오", account: "카카오뱅크", date: "20200918", price: 10000), .init(id: 0, label: 4, title: "이이", description: "오오", account: "농협", date: "20200918", price: 10000), .init(id: 0, label: 9, title: "이이", description: "오오", account: "블루베리스무디", date: "20201018", price: 10000)]
        }

        let loadTransactions = input.loadTransactions.asObservable()
            .withLatestFrom(isNextPageExists)
            .filter { $0 }
            .withLatestFrom(input.fetchTransactions.asObservable())
            .flatMap { [weak self] account -> Observable<NetworkingResult<TransactionResponse>> in
                guard let self = self else { return .never() }
                return Service.shared.fetchTransactions(account?.id, page: self.page)
        }
        .withLatestFrom(fetchTransactions) { [weak self] result, old -> [Transaction] in
            switch result {
            case .success(let response):
                self?.updatePage(response.isNextPageExists == "Y")
                return old + response.transactions
            case .noContent:
                break
            default:
                error.accept(ErrorMessage.plain)
            }
            return []
        }

        let transactions = Observable.concat([fetchTransactions, loadTransactions])
            .map { transactions -> [TransactionSectionModel] in
                var result = [String: [Transaction]]()
                for transaction in transactions {
                    let date = Format.dateStringToString(transaction.date)
                    if result[date] == nil {
                        result[date] = [transaction]
                        continue
                    }

                    result[date]?.append(transaction)
                }
                return result.compactMap { TransactionSectionModel(model: $0.key, items: $0.value) }
        }

        return .init(transactions: transactions.asDriver(onErrorJustReturn: []),
                     error: error.asSignal())
    }

    private func updatePage(_ isNextPageExists: Bool) {
        self.isNextPageExists.accept(isNextPageExists)
        if isNextPageExists { self.page += 1 }
    }
}
