//
//  NetworkingResults.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/09.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

enum NetworkingError: Error, Equatable {
    case tokenIsExpired
    case tokenIsRenewaled
}

enum NetworkingResult<T: Decodable & Equatable>: Equatable {
    case success(T)
    case noContent
    case fail
    case notFound
}
