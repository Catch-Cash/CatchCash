//
//  Color.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/07.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

protocol MakeColor {
    static func make(_ hex: String) -> UIColor
}

extension MakeColor {
    static func make(_ hex: String) -> UIColor {
        var rgbValue:UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

struct Color: MakeColor {
    // Category
    static let income = make("00B8A9")
    static let expense = make("F6416C")
    static let saving = make("FFCB33")

    static let transactionIncome = make("3EBBE8")
    static let transactionExpense = make("EA5455")

    // Label
    static let labelDefault = make("606060")
    static let label0 = make("4CD3C2")
    static let label1 = make("FFD460")
    static let label2 = make("55A5E8")
    static let label3 = make("FF8F4A")
    static let label4 = make("6072FF")
    static let label5 = make("9EEF6B")
    static let label6 = make("FF6060")
    static let label7 = make("ACACAC")
    static let label8 = make("CB6BEF")
    static let label9 = make("55E0F2")
    static let label10 = make("606060")

    // Util
    static let header = make("303030")
}
