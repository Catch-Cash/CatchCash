//
//  TransactionViewController.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/14.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxCocoa
import RxDataSources
import RxSwift

typealias TransactionSectionModel = SectionModel<String, Transaction>
typealias TransactionDataSource = RxTableViewSectionedReloadDataSource<TransactionSectionModel>

final class TransactionViewController: UIViewController {

    struct Constant {
        static let openHeight: CGFloat = 100
        static let closeHeight: CGFloat = 62
    }

    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var transactionTableView: UITableView!
    @IBOutlet weak var filterTableView: UITableView!
    @IBOutlet weak var filterTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var indicator: UIActivityIndicatorView!

    private let viewModel = TransactionViewModel()
    private let disposeBag = DisposeBag()
    private let fetchTransactions = BehaviorRelay<SimpleAccount?>(value: nil)
    private let loadTransactions = PublishRelay<Void>()

    private lazy var dataSource: TransactionDataSource = {
        let configureCell: (TableViewSectionedDataSource<TransactionSectionModel>, UITableView, IndexPath, Transaction)
            -> UITableViewCell = { _, tableView, indexPath, element in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.transactionCell, for: indexPath)
                    as? TransactionTableViewCell else { return .init() }
                cell.setup(element)
                return cell
        }

        return TransactionDataSource(configureCell: configureCell)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchTransactions.compactMap { $0 == nil ? "전체" : $0?.alias }
            .bind(to: filterButton.rx.title())
            .disposed(by: disposeBag)

        filterButton.rx.tap
            .bind { [weak self] _ in self?.toggleFilterTableView() }
            .disposed(by: disposeBag)

        setupTableView()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTransactions.accept(nil)
    }

    private func setupTableView() {
        transactionTableView.register(UINib(nibName: Identifier.transactionCell,
                                            bundle: nil),
                                      forCellReuseIdentifier: Identifier.transactionCell)
        transactionTableView.rx.setDelegate(self).disposed(by: disposeBag)

        filterTableView.rx.itemSelected.debug("😭")
            .bind { [weak self] indexPath in
                indexPath.row == 0
                    ? self?.fetchTransactions.accept(nil)
                    : self?.fetchTransactions.accept(AccountManager.accounts?[indexPath.row-1])
                self?.toggleFilterTableView()
        }
        .disposed(by: disposeBag)

        filterTableView.layer.cornerRadius = 8
        filterTableView.layer.shadowColor = UIColor.black.cgColor
        filterTableView.layer.shadowOffset = CGSize(width: 0, height: 2)
        filterTableView.layer.shadowOpacity = 0.16
        filterTableView.layer.shadowRadius = 8

        let headerView = UIView(frame: CGRect.init(x: 0, y: 0, width: 100, height: 26))
        let label = UILabel(frame: .init(x: 10, y: 8, width: 80, height: 10))
        let lineView = UIView(frame: .init(x: 10, y: 24, width: 80, height: 0.5))

        label.font = .systemFont(ofSize: 8, weight: .medium)
        label.textColor = Color.label10
        label.textAlignment = .center

        lineView.backgroundColor = Color.label10

        fetchTransactions.map { $0 == nil ? "전체" : $0?.alias }
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)

        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleFilterTableView))
        headerView.addGestureRecognizer(tap)

        headerView.addSubview(label)
        headerView.addSubview(lineView)

        filterTableView.sectionHeaderHeight = 26
        filterTableView.tableHeaderView = headerView

        Observable.just(AccountManager.accounts)
            .compactMap { accounts in
                guard let accounts = accounts else { return nil }
                return [SimpleAccount(id: "", alias: "전체")] + accounts
            }
            .do(onNext: { [weak self] accounts in
                self?.filterTableViewHeightConstraint.constant = CGFloat(34 + (accounts.count * 20))
            })
            .asDriver(onErrorJustReturn: [])
            .drive(filterTableView.rx.items(cellIdentifier: Identifier.filterCell, cellType: FilterTableViewCell.self)) { $2.setup($1) }
            .disposed(by: disposeBag)
    }

    private func bindViewModel() {
        let input = TransactionViewModel.Input(fetchTransactions: fetchTransactions.asDriver(),
                                               loadTransactions: loadTransactions.asSignal())
        let output = viewModel.transform(input: input)

        output.transactions
            .drive(transactionTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        output.error
            .emit(onNext: { [weak self] in self?.showToast($0) })
            .disposed(by: disposeBag)

        output.isLoading
            .emit(to: indicator.rx.isAnimating)
            .disposed(by: disposeBag)
    }

    @objc private func toggleFilterTableView() {
        filterTableView.isHidden.toggle()
    }
}

extension TransactionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cell = tableView.cellForRow(at: indexPath) as? TransactionTableViewCell
            else { return Constant.closeHeight }
        return cell.isOpened ? Constant.openHeight : Constant.closeHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.performBatchUpdates({
            guard let cell = tableView.cellForRow(at: indexPath) as? TransactionTableViewCell else { return }
            if cell.isEditingMode {
                self.showToast("수정 중에는 닫을 수 없습니다")
                return
            }
            cell.isOpened.toggle()
            tableView.setNeedsLayout()
        }, completion: nil)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 40))

        let label = UILabel(frame: .init(x: 8, y: 24, width: 100, height: 16))
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = Color.header
        label.text = dataSource.sectionModels[section].model
        label.textAlignment = .left

        headerView.addSubview(label)

        return headerView
    }
}

final class FilterTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    var id: String = ""

    func setup(_ account: SimpleAccount) {
        id = account.id
        titleLabel.text = account.alias
    }
}
