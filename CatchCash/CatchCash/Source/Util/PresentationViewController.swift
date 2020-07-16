//
//  PresentationViewController.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/16.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

final class PresentationController: UIPresentationController {

    private let presentedHeight: CGFloat = 260
    private var direction: CGFloat = 0
    private lazy var dimmingView: UIView! = {
        guard let container = containerView else { return nil }

        let view = UIView(frame: container.bounds)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTap(tap:)))
        )

        return view
    }()

    @objc func didTap(tap: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let container = containerView else { return .zero }

        return CGRect(x: 0, y: container.bounds.height - self.presentedHeight,
                      width: container.bounds.width, height: container.bounds.height - self.presentedHeight)
    }

    override func presentationTransitionWillBegin() {
        guard let container = containerView,
            let coordinator = presentingViewController.transitionCoordinator else { return }

        dimmingView.alpha = 0
        container.addSubview(dimmingView)
        dimmingView.addSubview(presentedViewController.view)

        coordinator.animate(alongsideTransition: { [weak self] context in
            guard let self = self else { return }

            self.dimmingView.alpha = 1
            }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentingViewController.transitionCoordinator else { return }

        coordinator.animate(alongsideTransition: { [weak self] context in
            guard let `self` = self else { return }

            self.dimmingView.alpha = 0
            }, completion: nil)
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView.removeFromSuperview()
        }
    }

}
