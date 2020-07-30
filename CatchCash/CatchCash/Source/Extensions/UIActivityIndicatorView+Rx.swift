//
//  Spinner+Rx.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/26.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

extension Reactive where Base: UIActivityIndicatorView {
  var isAnimating: Binder<Bool> {
    return Binder(self.base) { view, active in
      if active {
        view.startAnimating()
        view.isHidden = false
      } else {
        view.stopAnimating()
        view.isHidden = true
      }
    }
  }
}
