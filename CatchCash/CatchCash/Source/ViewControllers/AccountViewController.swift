//
//  AccountViewController.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/09.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import AlignedCollectionViewFlowLayout
import RxCocoa
import RxSwift

final class AccountViewController: UIViewController {

    struct Constant {
        static let openHeight: CGFloat = 235
        static let closeHeight: CGFloat = 110
    }

    @IBOutlet weak var accountManageButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var accountCountLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: AlignedCollectionViewFlowLayout! {
        didSet {
            collectionViewFlowLayout.verticalAlignment = .top
            collectionViewFlowLayout.horizontalAlignment = .justified
        }
    }
    @IBOutlet weak var indicator: UIActivityIndicatorView!

    private let viewModel = AccountViewModel()
    private let disposeBag = DisposeBag()
    private let fetchAccouts = BehaviorRelay<Void>(value: ())
    private let logoutTaps = PublishRelay<Void>()
    private let deleteUserTaps = PublishRelay<Void>()
    private let accounts = BehaviorSubject<[(Account, CAGradientLayer)]>(value: [])

    override func viewDidLoad() {
        super.viewDidLoad()

        checkLogin()

        collectionView.register(UINib(nibName: Identifier.accountCell,
                                      bundle: nil),
                                forCellWithReuseIdentifier: Identifier.accountCell)

        refreshButton.rx.tap
            .bind(to: fetchAccouts)
            .disposed(by: disposeBag)
        accountManageButton.rx.tap
            .bind { [weak self] _ in
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

    private func checkLogin() {
        if TokenManager.accessToken != nil { return }
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: Identifier.loginVC) else { return }
        self.navigationController?.setViewControllers([vc], animated: false)
    }

    private func bindViewModel() {
        let input = AccountViewModel.Input(fetchAccounts: fetchAccouts.asDriver(),
                                           logoutTaps: logoutTaps.asSignal(),
                                           deleteUserTaps: deleteUserTaps.asSignal())
        let output = viewModel.transform(input: input)

        output.accounts
            .do(afterNext: { [weak self] _ in self?.collectionView.reloadData() })
            .drive(accounts)
            .disposed(by: disposeBag)

        output.accounts
            .map { "\($0.count)" }
            .drive(accountCountLabel.rx.text)
            .disposed(by: disposeBag)

        output.presentLogin
            .emit(onNext: { [weak self] _ in
                TokenManager.clear()
                AccountManager.clear()
                self?.checkLogin()
            })
            .disposed(by: disposeBag)

        output.error
            .emit(onNext: { [weak self] in self?.showToast($0) })
            .disposed(by: disposeBag)

        output.isLoading
            .emit(to: indicator.rx.isAnimating)
            .disposed(by: disposeBag)
    }
}

extension AccountViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (try? accounts.value().count) ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let accounts = try? accounts.value(),
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Identifier.accountCell,
                for: indexPath
                ) as? AccountCollectionViewCell else { return UICollectionViewCell() }

        let (account, layer) = accounts[indexPath.row]
        cell.setup(account, layer)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.performBatchUpdates({
            guard let cell = collectionView.cellForItem(at: indexPath) as? AccountCollectionViewCell else { return }
            if cell.isEditingMode {
                self.showToast("수정 중에는 닫을 수 없습니다")
                return
            }
            cell.isOpened.toggle()
            collectionView.setNeedsLayout()
        }, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width / 2) - 6
        if let cell = collectionView.cellForItem(at: indexPath) as? AccountCollectionViewCell {
            let height = cell.isOpened ? Constant.openHeight - cell.minusHeight : Constant.closeHeight
            return .init(width: width, height: height)
        }

        return .init(width: width, height: Constant.closeHeight)
    }
}
