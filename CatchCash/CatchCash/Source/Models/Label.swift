//
//  Label.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/09.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

enum Label: Int {
    case food = 0
    case familyOccasion
    case saving
    case culture
    case transportation
    case medical
    case living
    case pet
    case fashion
    case income

    init(_ rawValue: Int) {
        if rawValue > 9 { self = .food }
        self.init(rawValue: rawValue)!
    }
}

extension Label {
    var title: String {
        switch self {
        case .food: return "음식"
        case .familyOccasion: return "경조"
        case .saving: return "저축"
        case .culture: return "문화"
        case .transportation: return "교통"
        case .medical: return "의료"
        case .living: return "주거"
        case .pet: return "반려동물"
        case .fashion: return "패션 미용"
        case .income: return "수입"
        }
    }

    var color: UIColor {
        switch self {
        case .food: return Color.label0
        case .familyOccasion: return Color.label1
        case .saving: return Color.label2
        case .culture: return Color.label3
        case .transportation: return Color.label4
        case .medical: return Color.label5
        case .living: return Color.label6
        case .pet: return Color.label7
        case .fashion: return Color.label8
        case .income: return Color.label9
        }
    }
}
