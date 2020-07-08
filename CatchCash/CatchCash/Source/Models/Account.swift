//
//  Account.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/08.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

struct Account: Decodable {
    let id: String
    let bank: String
    let alias: String
    let banlance: String
    let transactions: [SimpleTransaction]

    enum CodingKeys: String, CodingKey {
        case id = "fintech_use_num"
        case bank = "bank_name"
        case alias = "account_alias"
        case banlance = "banlance_amt"
        case transactions = "transaction_list"
    }
}

struct SimpleTransaction: Decodable {
    let price: Int
    let label: Int

    enum CodingKeys: String, CodingKey {
        case price = "tran_amt"
        case label = "label"
    }
}
