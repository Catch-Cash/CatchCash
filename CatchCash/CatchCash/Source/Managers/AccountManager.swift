//
//  AccountManager.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/09.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

struct AccountManager {
    private static let ud = UserDefaults.standard

    static var accounts: [SimpleAccount]? {
        get {
            guard let data = ud.data(forKey: "accounts") else { return nil }
            let accounts = try? JSONDecoder().decode([SimpleAccount].self, from: data)
            return accounts
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            ud.set(data, forKey: "accounts")
        }
    }

    static func clear() {
        ud.set(nil, forKey: "accounts")
    }
}
