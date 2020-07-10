//
//  UIViewController.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/10.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

extension UIViewController {
    func showToast(_ message: String) {
        self.view.addSubview(ToastView(message))
    }
}
