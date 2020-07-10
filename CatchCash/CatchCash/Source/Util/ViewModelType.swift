//
//  ViewModelType.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/09.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}
