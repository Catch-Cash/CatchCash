//
//  Transaction.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/08.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

struct Transaction: Encodable {
    let id: Int
    let label: Int
    let title: String
    let description: String

    enum CodingKeys: String, CodingKey {
        case id = "transaction_id"
        case title = "print_content"
    }
}
