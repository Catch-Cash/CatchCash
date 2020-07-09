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

    static var accounts: [SimpleAccount] {
        get {
            return ud.array(forKey: "accounts") as? [SimpleAccount] ?? []
        }
        set {
            ud.set(newValue, forKey: "accounts")
        }
    }

    static func clear() {
        ud.set(nil, forKey: "accounts")
    }
}
