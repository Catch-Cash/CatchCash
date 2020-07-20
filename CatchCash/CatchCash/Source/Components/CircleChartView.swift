//
//  CircleChartView.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/07.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

final class CircleChartView: UIView {

    var percent: CGFloat = 0

    override func draw(_ rect: CGRect) {
        let rect = superview?.bounds ?? rect
        self.backgroundColor = .clear
        let start: CGFloat = -(.pi) / 2
        let end = (percent / 100) * (.pi * 2)
        let path = UIBezierPath(arcCenter: .init(x: rect.midX, y: rect.midY),
                                radius: rect.midX - 8,
                                startAngle: start,
                                endAngle: end + start,
                                clockwise: true)
        UIColor.white.set()
        path.lineWidth = 12
        path.lineCapStyle = .round
        path.stroke()
    }
}
