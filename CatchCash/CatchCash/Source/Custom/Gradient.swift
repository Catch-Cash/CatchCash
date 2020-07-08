//
//  Gradient.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/07.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

struct Gradient: MakeColor {

    // Category
    static func make(_ category: UsageCategory) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.locations = [0.0, 0.5, 1.0]
        switch category {
        case .income: layer.colors = [make("00B8A9"), make("32C5B9"), make("64D2C9")]
        case .expense: layer.colors = [make("F6416C"), make("F66588"), make("F78AA4")]
        case .saving: layer.colors = [make("FFCB33"), make("FED45A"), make("FDDD82")]
        }
        return layer
    }

    // Account
    static func make(_ account: Int) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.locations = [0.0, 1.0]
        switch account {
        case 1: layer.colors = [make("FE946E"), make("FEA98B")]
        case 2: layer.colors = [make("46CDCF"), make("6BD7D8")]
        case 3: layer.colors = [make("FEA3A7"), make("FEB5B8")]
        case 4: layer.colors = [make("8388FF"), make("9B9FFF")]
        case 5: layer.colors = [make("91DE94"), make("A7E4A9")]
        case 6: layer.colors = [make("E594E2"), make("EAA9E7")]
        case 7: layer.colors = [make("7BD4F5"), make("95DCF7")]
        case 8: layer.colors = [make("EB7474"), make("EF8F8F")]
        default: break
        }
        return layer
    }
}
