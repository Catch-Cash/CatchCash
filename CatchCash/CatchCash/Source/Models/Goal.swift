//
//  Goal.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/08.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

struct Goal: Decodable & Equatable {
    let goal: Int
    let current: Int
    let achievementRate: Int

    enum CodingKeys: String, CodingKey {
        case goal = "goal_amount"
        case current = "current_amount"
        case achievementRate = "achievement_rate"
    }
}
