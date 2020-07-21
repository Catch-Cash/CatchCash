//
//  API.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/08.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

import Alamofire

enum API {
    case login
    case logout
    case deleteUser
    case renewalToken
    case account
    case updateAccount(id: String, alias:String)
    case transaction(id: String?, page: Int)
    case updateTransaction(Transaction)
    case goal
    case updateGoal(UsageCategory, goal: Int)
}

extension API {
    var baseURL: String {
      return "http://10.156.145.162:1212"
    }

    var path: String {
        switch self {
        case .login:
            return "/autorize"

        case .logout:
            return "/logout"

        case .deleteUser:
            return "/user"

        case .renewalToken:
            return "/token"

        case .account, .updateAccount:
            return "/account"

        case .transaction(let id, _):
            if let id = id {
                return "account/list/" + id
            }
            return "account/list/"

        case .updateTransaction:
            return "/account/list"

        case .goal, .updateGoal:
            return "/goal"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .logout, .account, .transaction, .goal:
            return .get

        case .renewalToken:
            return .post

        case .updateAccount, .updateTransaction, .updateGoal:
            return .patch

        case .deleteUser:
            return .delete
        }
    }

    var headers: HTTPHeaders? {
        switch self {
        case .logout,
             .deleteUser,
             .account,
             .updateAccount,
             .transaction,
             .updateTransaction,
             .goal,
             .updateGoal:
            guard let token = TokenManager.accessToken else { return nil }
            return ["Authorization": token]

        default:
            return nil
        }
    }

    var parameters: Parameters? {
        switch self {
        case .renewalToken:
            return ["access_token": TokenManager.accessToken,
                    "refresh_token": TokenManager.refreshToken]

        case .updateAccount(let id, let alias):
            return ["fintech_use_num": id, "account_alias": alias]

        case .transaction(_, let page):
            return ["page_num": page]

        case .updateTransaction(let transaction):
            return transaction.dictionary

        case .updateGoal(let category, let goal):
            return ["category": category.string, "goal_amount": goal]

        default:
            return nil
        }
    }
}

private extension Encodable {
  var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments))
        .flatMap { $0 as? [String: Any] }
  }
}
