//
//  TokenManager.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/08.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

struct TokenManager {
    private static let ud = UserDefaults.standard

    static var accessToken: String {
        get {
            return ud.string(forKey: "accessToken") ?? ""
        }
        set {
            ud.set(newValue, forKey: "accessToken")
        }
    }
    static var refreshToken: String {
        get {
            return ud.string(forKey: "refreshToken") ?? ""
        }
        set {
            ud.set(newValue, forKey: "refreshToken")
        }
    }

    static func clear() {
        ud.set(nil, forKey: "accessToken")
        ud.set(nil, forKey: "refreshToken")
    }
}
