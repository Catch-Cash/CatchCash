//
//  UsageCategory.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/07.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

enum UsageCategory: Int {
    case income = 0
    case expense
    case saving
}

extension UsageCategory {
    var title: String {
        switch self {
        case .income: return "수입"
        case .expense: return "지출"
        case .saving: return "저축"
        }
    }

    var string: String {
        return String(describing: self)
    }

    var color: UIColor {
        switch self {
        case .income: return Color.income
        case .expense: return Color.expense
        case .saving: return Color.saving
        }
    }

    var gradient: CAGradientLayer {
        return Gradient.make(self)
    }
}
