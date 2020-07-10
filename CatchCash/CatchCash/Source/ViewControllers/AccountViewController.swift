//
//  AccountViewController.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/09.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

final class AccountViewController: UIViewController {

    @IBOutlet weak var accountManageButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var accountCountLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    private let viewModel = AccountViewModel()
    private let disposeBag = DisposeBag()
    private let fetchAccouts = BehaviorRelay<Void>(value: ())
    private let logoutTaps = PublishRelay<Void>()
    private let deleteUserTaps = PublishRelay<Void>()

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshButton.rx.tap.bind(to: fetchAccouts).disposed(by: disposeBag)
        accountManageButton.rx.tap.bind { [weak self] _ in
            guard let self = self else { return }
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(.init(title: "취소", style: .cancel, handler: nil))
            alert.addAction(.init(title: "로그아웃",
                                  style: .default,
                                  handler: { _ in self.logoutTaps.accept(()) }))
            alert.addAction(.init(title: "탈퇴",
                                  style: .destructive,
                                  handler: { _ in self.deleteUserTaps.accept(()) }))
            self.present(alert, animated: true, completion: nil)
        }
        .disposed(by: disposeBag)

        bindViewModel()
    }

    private func bindViewModel() {
        let input = AccountViewModel.Input(fetchAccounts: fetchAccouts.asDriver(),
                                           logoutTaps: logoutTaps.asSignal(),
                                           deleteUserTaps: deleteUserTaps.asSignal())
        let output = viewModel.transform(input: input)

        output.accounts
            .drive(
                collectionView.rx.items(cellIdentifier: Identifier.accountCell,
                                        cellType: AccountCollectionViewCell.self)
            ) { $2.setup($1.0, $1.1) }
            .disposed(by: disposeBag)

        output.accounts
            .map { "\($0.count)" }
            .drive(accountCountLabel.rx.text)
            .disposed(by: disposeBag)

        output.presentLogin
            .emit(onNext: { [weak self] _ in
                guard let vc = self?.storyboard?
                    .instantiateViewController(withIdentifier: Identifier.loginVC) else { return }
                self?.present(vc, animated: false, completion: nil)
            })
            .disposed(by: disposeBag)

        output.error
            .emit(onNext: { [weak self] in self?.showToast($0) })
            .disposed(by: disposeBag)
    }
}
