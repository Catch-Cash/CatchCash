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
        let isLoading: Signal<Bool>
    }

    private let isNextPageExists = BehaviorRelay<Bool>(value: false)
    private var page = 1
    private let disposeBag = DisposeBag()

    func transform(input: Input) -> Output {
        let error = PublishRelay<String>()
        let isLoading = PublishRelay<Bool>()

        let fetchTransactions = input.fetchTransactions.asObservable()
            .do(onNext: { _ in isLoading.accept(true) })
            .flatMap { Service.shared.fetchTransactions($0?.id) }
            .map { [weak self] result -> [Transaction] in
                defer { isLoading.accept(false) }
                switch result {
                case .success(let response):
                    self?.updatePage(response.isNextPageExists == "y")
                    return response.transactions
                case .noContent:
                    error.accept(ErrorMessage.noContent)
                default:
                    error.accept(ErrorMessage.plain)
                }
                return []
        }

        let loadTransactions = input.loadTransactions.asObservable()
            .withLatestFrom(isNextPageExists)
            .filter { $0 }
            .do(onNext: { _ in isLoading.accept(true) })
            .withLatestFrom(input.fetchTransactions.asObservable())
            .flatMap { [weak self] account -> Observable<NetworkingResult<TransactionResponse>> in
                guard let self = self else { return .never() }
                return Service.shared.fetchTransactions(account?.id, page: self.page)
            }
            .withLatestFrom(fetchTransactions) { [weak self] result, old -> [Transaction] in
                defer { isLoading.accept(false) }
                switch result {
                case .success(let response):
                    self?.updatePage(response.isNextPageExists == "y")
                    return old + response.transactions
                case .noContent:
                    error.accept(ErrorMessage.noContent)
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
                    .sorted { $0.model < $1.model }
        }

        return .init(transactions: transactions.asDriver(onErrorJustReturn: []),
                     error: error.asSignal(),
                     isLoading: isLoading.asSignal())
    }

    private func updatePage(_ isNextPageExists: Bool) {
        self.isNextPageExists.accept(isNextPageExists)
        if isNextPageExists { self.page += 1 }
    }
}
