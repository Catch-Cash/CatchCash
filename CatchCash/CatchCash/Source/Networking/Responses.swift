//
//  Responses.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/08.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

struct AccountResponse: Decodable {
    let accounts: [Account]

    enum CodingKeys: String, CodingKey {
        case accounts = "account_list"
    }
}

struct TransactionResponse: Decodable {
    let transactions: [Transaction]
    let isNextPageExists: String

    enum CodingKeys: String, CodingKey {
        case transactions = "transaction_list"
        case isNextPageExists = "next_page_yn"
    }
}

struct GoalResponse: Decodable {
    let income: Goal
    let expense: Goal
    let saving: Goal
}
