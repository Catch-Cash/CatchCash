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
    @IBOutlet weak var tableView: UITableView!

    private let viewModel = TransactionViewModel()
    private let disposeBag = DisposeBag()
    private let fetchTransactions = BehaviorRelay<String?>(value: nil)
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

        tableView.register(UINib(nibName: Identifier.transactionCell,
                                 bundle: nil),
                           forCellReuseIdentifier: Identifier.transactionCell)
        tableView.rx.setDelegate(self).disposed(by: disposeBag)

        bindViewModel()
    }

    private func bindViewModel() {
        let input = TransactionViewModel.Input(fetchTransactions: fetchTransactions.asDriver(),
                                               loadTransactions: loadTransactions.asSignal())
        let output = viewModel.transform(input: input)

        output.transactions
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        output.error
            .emit(onNext: { [weak self] in self?.showToast($0) })
            .disposed(by: disposeBag)
    }
}

extension TransactionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cell = tableView.cellForRow(at: indexPath) as? TransactionTableViewCell
            else { return Constant.closeHeight }
        return cell.isOpened ? Constant.openHeight : Constant.closeHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 40))

        let label = UILabel(frame: .init(x: 8, y: 24, width: 100, height: 16))
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = Color.header
        label.text = dataSource.sectionModels[section].model
        label.textAlignment = .left

        headerView.addSubview(label)

        return headerView
    }
}
