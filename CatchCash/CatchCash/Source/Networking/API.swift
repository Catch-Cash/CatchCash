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
    case updateAccount(fintechNum: String, alias:String)
    case transaction(fintechNum: String?)
    case updateTranscation(Transaction)
    case goal
    case updateGoal(UsageCategory, goal: Int)
}

extension API {
    var baseURL: String {
      return ""
    }

    var path: String {
        switch self {
        case .login:
            return "/login"

        case .logout:
            return "/logout"

        case .deleteUser:
            return "/user"

        case .renewalToken:
            return "/token"

        case .account, .updateAccount:
            return "/account"

        case .transaction(let fintechNum):
            if let fintechNum = fintechNum {
                return "account/list/" + fintechNum
            }
            return "account/list/"

        case .updateTranscation:
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

        case .updateAccount, .updateTranscation, .updateGoal:
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
             .updateTranscation,
             .goal,
             .updateGoal:
            return ["Authorization": TokenManager.accessToken]

        default:
            return nil
        }
    }

    var parameters: Parameters? {
        switch self {
        case .renewalToken:
            return ["access_token": TokenManager.accessToken,
                    "refresh_token": TokenManager.refreshToken]

        case .updateAccount(let fintechNum, let alias):
            return ["fintech_use_num": fintechNum, "account_alias": alias]

        case .updateTranscation(let transaction):
            return transaction.dictionary

        case .updateGoal(let category, let goal):
            return ["category": category.rawValue, "goal_amount": goal]

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
