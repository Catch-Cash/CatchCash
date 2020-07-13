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
        case .income: layer.colors = [make("00B8A9").cgColor, make("32C5B9").cgColor, make("64D2C9").cgColor]
        case .expense: layer.colors = [make("F6416C").cgColor, make("F66588").cgColor, make("F78AA4").cgColor]
        case .saving: layer.colors = [make("FFCB33").cgColor, make("FED45A").cgColor, make("FDDD82").cgColor]
        }
        return layer
    }

    // Account
    static func make(_ account: Int) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.locations = [0.0, 1.0]
        switch account {
        case 0: layer.colors = [make("FE946E").cgColor, make("FEA98B").cgColor]
        case 1: layer.colors = [make("46CDCF").cgColor, make("6BD7D8").cgColor]
        case 2: layer.colors = [make("FEA3A7").cgColor, make("FEB5B8").cgColor]
        case 3: layer.colors = [make("8388FF").cgColor, make("9B9FFF").cgColor]
        case 4: layer.colors = [make("91DE94").cgColor, make("A7E4A9").cgColor]
        case 5: layer.colors = [make("E594E2").cgColor, make("EAA9E7").cgColor]
        case 6: layer.colors = [make("7BD4F5").cgColor, make("95DCF7").cgColor]
        case 7: layer.colors = [make("EB7474").cgColor, make("EF8F8F").cgColor]
        default: break
        }
        return layer
    }
}
