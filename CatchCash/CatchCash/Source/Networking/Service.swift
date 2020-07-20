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

private func requestData(_ api: API, encoding: ParameterEncoding = URLEncoding.default)
    -> Observable<(HTTPURLResponse, Data)> {
        return requestData(api.method,
                           api.baseURL + api.path,
                           parameters: api.parameters,
                           encoding: JSONEncoding.prettyPrinted,
                           headers: api.headers)
}

protocol APIProvider {
    func login()  -> Observable<NetworkingResult<Bool>>
    func logout() -> Observable<NetworkingResult<Bool>>
    func deleteUser() -> Observable<NetworkingResult<Bool>>
    func renewalToken() -> Observable<NetworkingResult<Bool>>

    func fetchAccounts() -> Observable<NetworkingResult<[Account]>>
    func updateAccount(_ id: String, alias: String) -> Observable<NetworkingResult<Bool>>
    func fetchTransactions(_ id: String?, page: Int) -> Observable<NetworkingResult<TransactionResponse>>
    func updateTransaction(_ transaction: Transaction) -> Observable<NetworkingResult<Bool>>
    func fetchGoals() -> Observable<NetworkingResult<GoalResponse>>
    func updateGoal(_ category: UsageCategory, goal: Int) -> Observable<NetworkingResult<Goal>>
}

final class Service: APIProvider {
    static let shared = Service()
    private init() { }

    private let decoder = JSONDecoder()

    func login() -> Observable<NetworkingResult<Bool>> {
        return requestData(.login)
            .map { [weak self] response, data -> NetworkingResult<Bool> in
                switch response.statusCode {
                case 200:
                    guard let tokens = try? self?.decoder.decode(TokenResponse.self, from: data)
                        else { return .fail }
                    TokenManager.accessToken = tokens.accessToken
                    TokenManager.refreshToken = tokens.refreshToken
                    return .noContent
                default:
                    return .fail
                }
        }
        .retry(2)
    }

    func logout() -> Observable<NetworkingResult<Bool>> {
        return requestData(.logout)
            .map { response, _ -> NetworkingResult<Bool> in
                switch response.statusCode {
                case 200: return .noContent
                case 403: throw NetworkingError.tokenIsExpired
                default: return .fail
                }
        }
        .catchError { [weak self] err -> Observable<NetworkingResult<Bool>> in
            guard let error = err as? NetworkingError, let self = self else { return .just(.fail) }
            if error == .tokenIsExpired {
                return self.renewalToken()
                    .map {
                        if $0 == .noContent { throw NetworkingError.tokenIsRenewaled }
                        return .fail
                }
            }
            return .just(.fail)
        }
        .retry()
    }

    func deleteUser() -> Observable<NetworkingResult<Bool>> {
        return requestData(.deleteUser)
            .map { response, _ -> NetworkingResult<Bool> in
                switch response.statusCode {
                case 200: return .noContent
                case 403: throw NetworkingError.tokenIsExpired
                case 404: return .notFound
                default: return .fail
                }
        }
        .catchError { [weak self] err -> Observable<NetworkingResult<Bool>> in
            guard let error = err as? NetworkingError, let self = self else { return .just(.fail) }
            if error == .tokenIsExpired {
                return self.renewalToken()
                    .map {
                        if $0 == .noContent { throw NetworkingError.tokenIsRenewaled }
                        return .fail
                }
            }
            return .just(.fail)
        }
        .retry()
    }

    func renewalToken() -> Observable<NetworkingResult<Bool>> {
        return requestData(.renewalToken)
            .map { [weak self] response, data -> NetworkingResult<Bool> in
                switch response.statusCode {
                case 200:
                    guard let tokens = try? self?.decoder.decode(TokenResponse.self, from: data)
                        else { return .fail }
                    TokenManager.accessToken = tokens.accessToken
                    TokenManager.refreshToken = tokens.refreshToken
                    return .noContent
                default: return .fail
                }
        }
    }

    func fetchAccounts() -> Observable<NetworkingResult<[Account]>> {
        return requestData(.account)
            .map { [weak self] response, data -> NetworkingResult<[Account]> in
                switch response.statusCode {
                case 200:
                    guard let accountResponse = try? self?.decoder.decode(AccountResponse.self, from: data)
                        else { return .fail }
                    AccountManager.accounts = accountResponse.accounts.map { $0.toSimpleAccount() }
                    return .success(accountResponse.accounts)
                case 404: return .notFound
                default: return .fail
                }
        }
        .catchError { [weak self] err -> Observable<NetworkingResult<[Account]>> in
            guard let error = err as? NetworkingError, let self = self else { return .just(.fail) }
            if error == .tokenIsExpired {
                return self.renewalToken()
                    .map {
                        if $0 == .noContent { throw NetworkingError.tokenIsRenewaled }
                        return .fail
                }
            }
            return .just(.fail)
        }
        .retry()
    }

    func updateAccount(_ id: String, alias: String) -> Observable<NetworkingResult<Bool>> {
        return requestData(.updateAccount(id: id, alias: alias))
            .map { response, _ -> NetworkingResult<Bool> in
                switch response.statusCode {
                case 200: return .noContent
                case 404: return .notFound
                default: return .fail
                }
        }
        .catchError { [weak self] err -> Observable<NetworkingResult<Bool>> in
            guard let error = err as? NetworkingError, let self = self else { return .just(.fail) }
            if error == .tokenIsExpired {
                return self.renewalToken()
                    .map {
                        if $0 == .noContent { throw NetworkingError.tokenIsRenewaled }
                        return .fail
                }
            }
            return .just(.fail)
        }
        .retry()
    }

    func fetchTransactions(_ id: String?, page: Int = 1) -> Observable<NetworkingResult<TransactionResponse>> {
        return requestData(.transaction(id: id, page: page), encoding: URLEncoding.queryString)
            .map { [weak self] response, data -> NetworkingResult<TransactionResponse> in
                switch response.statusCode {
                case 200:
                    guard let transactionResponse = try? self?.decoder.decode(TransactionResponse.self, from: data)
                        else { return .fail }
                    return .success(transactionResponse)
                default: return .fail
                }
        }
        .catchError { [weak self] err -> Observable<NetworkingResult<TransactionResponse>> in
            guard let error = err as? NetworkingError, let self = self else { return .just(.fail) }
            if error == .tokenIsExpired {
                return self.renewalToken()
                    .map {
                        if $0 == .noContent { throw NetworkingError.tokenIsRenewaled }
                        return .fail
                }
            }
            return .just(.fail)
        }
        .retry()
    }

    func updateTransaction(_ transaction: Transaction) -> Observable<NetworkingResult<Bool>> {
        return requestData(.updateTransaction(transaction))
            .map { response, _ -> NetworkingResult<Bool> in
                switch response.statusCode {
                case 200: return .noContent
                case 404: return .notFound
                default: return .fail
                }
        }
        .catchError { [weak self] err -> Observable<NetworkingResult<Bool>> in
            guard let error = err as? NetworkingError, let self = self else { return .just(.fail) }
            if error == .tokenIsExpired {
                return self.renewalToken()
                    .map {
                        if $0 == .noContent { throw NetworkingError.tokenIsRenewaled }
                        return .fail
                }
            }
            return .just(.fail)
        }
        .retry()
    }

    func fetchGoals() -> Observable<NetworkingResult<GoalResponse>> {
        return requestData(.goal)
            .map { [weak self] response, data -> NetworkingResult<GoalResponse> in
                switch response.statusCode {
                case 200:
                    guard let goalResponse = try? self?.decoder.decode(GoalResponse.self, from: data)
                        else { return .fail }
                    return .success(goalResponse)
                default: return .fail
                }
        }
        .catchError { [weak self] err -> Observable<NetworkingResult<GoalResponse>> in
            guard let error = err as? NetworkingError, let self = self else { return .just(.fail) }
            if error == .tokenIsExpired {
                return self.renewalToken()
                    .map {
                        if $0 == .noContent { throw NetworkingError.tokenIsRenewaled }
                        return .fail
                }
            }
            return .just(.fail)
        }
        .retry()
    }

    func updateGoal(_ category: UsageCategory, goal: Int) -> Observable<NetworkingResult<Goal>> {
        return requestData(.updateGoal(category, goal: goal))
            .map { [weak self] response, data -> NetworkingResult<Goal> in
                switch response.statusCode {
                case 200:
                    guard let goal = try? self?.decoder.decode(Goal.self, from: data) else { return .fail }
                    return .success(goal)
                default: return .fail
                }
        }
        .catchError { [weak self] err -> Observable<NetworkingResult<Goal>> in
            guard let error = err as? NetworkingError, let self = self else { return .just(.fail) }
            if error == .tokenIsExpired {
                return self.renewalToken()
                    .map {
                        if $0 == .noContent { throw NetworkingError.tokenIsRenewaled }
                        return .fail
                }
            }
            return .just(.fail)
        }
        .retry()
    }
}

