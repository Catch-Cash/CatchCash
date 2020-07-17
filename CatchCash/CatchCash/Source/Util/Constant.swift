//
//  Constantu7877.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/09.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

struct ErrorMessage {
    static let plain = "오류가 발생했습니다"
    static let notFound = "정보를 찾을 수 없습니다."
}

struct Message {
    static let text = "수정할 텍스트를 선택해주세요"
    static let textAndLabel = "수정할 텍스트나 라벨을 선택해주세요"
}

struct Identifier {
    static let accountCell = "AccountCollectionViewCell"
    static let transactionCell = "TransactionTableViewCell"
    static let labelCell = "LabelCollectionViewCell"
    static let filterCell = "FilterTableViewCell"
    
    static let loginVC = "LoginViewController"
    static let labelVC = "LabelPickerViewController"
}

private let dateFormatter = DateFormatter()

struct Format {
    static let plain = "yyyyMMdd"
    static let sectionHeader = "M월 d일"

    static func dateStringToString(_ string: String?) -> String {
        dateFormatter.dateFormat = plain
        guard let date = dateFormatter.date(from: string ?? "") else { return "" }
        dateFormatter.dateFormat = sectionHeader
        return dateFormatter.string(from: date)
    }
}
