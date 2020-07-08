//
//  Service.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/08.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

import Alamofire
import RxAlamofire
import RxSwift

private func requestData(_ api: API) -> Single<(HTTPURLResponse, Data)> {
    return requestData(api.method,
                       api.baseURL + api.path,
                       parameters: api.parameters,
                       encoding: JSONEncoding.prettyPrinted,
                       headers: api.headers).asSingle()
}

protocol APIProvider {
    func login() -> Single<Bool>
    func logout() -> Single<Bool>
    func deleteUser() -> Single<Bool>
    func renewalToken() -> Single<Bool>

    func fetchAccount() -> Single<[Account]?>
    func updateAccount(_ id: String, alias: String) -> Single<Bool>
    func fetchTransaction(_ id: String?) -> Single<TransactionResponse?>
    func updateTransaction(_ transaction: Transaction) -> Single<Bool>
    func fetchGoal() -> Single<GoalResponse?>
    func updateGoal(_ category: UsageCategory, goal: Int) -> Single<Bool>
}
