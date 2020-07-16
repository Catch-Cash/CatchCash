//
//  TransactionHistoryTableViewCell.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/07.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

final class TransactionTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var labelButton: UIButton!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var editingButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var priceLabel: UILabel!

    var isOpened = false {
        didSet {
            editingButton.isHidden = !isOpened
            descriptionTextView.isHidden = !isOpened
        }
    }
    var isEditingMode = false {
        didSet {
            editingButton.isSelected = isEditingMode
            labelButton.isEnabled = isEditingMode
            titleTextField.isEnabled = isEditingMode
            descriptionTextView.isEditable = isEditingMode
        }
    }

    private var defaultTransaction: Transaction!
    private let disposeBag = DisposeBag()
    private let viewModel = TransactionTableViewCellModel()
    private let currentLabel = BehaviorRelay<Label>(value: .none)

    override func awakeFromNib() {
        super.awakeFromNib()
        titleTextField.delegate = self
        labelButton.layer.cornerRadius = labelButton.bounds.height / 2
        containerView.layer.cornerRadius = 8
        self.backgroundColor = nil
        
        labelButton.rx.tap
            .bind { [weak self] _ in self?.presentLabelPicker() }
            .disposed(by: disposeBag)

        currentLabel.bind { [weak self] label in
            self?.labelButton.setTitle(label.title, for: .normal)
            self?.labelButton.backgroundColor = label.color
        }
        .disposed(by: disposeBag)

        setupToolBar()
        bindViewModel()
    }

    func setup(_ transaction: Transaction) {
        defaultTransaction = transaction

        let label = Label(transaction.label)
        currentLabel.accept(label)
        accountLabel.text = transaction.account
        titleTextField.text = transaction.title
        descriptionTextView.text = transaction.description
        priceLabel.text = (label == .income ? "+" : "-") + "\(transaction.price ?? 0) 원"
        priceLabel.textColor = label == .income ? Color.transactionIncome : Color.transactionExpense
    }

    private func setupToolBar() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let barButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        toolBar.items = [barButton]
        toolBar.tintColor = #colorLiteral(red: 1, green: 0.5531694889, blue: 0.3933998346, alpha: 1)

        titleTextField.inputAccessoryView = toolBar
        descriptionTextView.inputAccessoryView = toolBar
    }

    @objc private func dismissKeyboard() {
        titleTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
    }

    private func presentLabelPicker() {
        guard let vc = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: Identifier.labelVC) as? LabelPickerViewController else { return }
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        vc.selectedLabel.bind(to: currentLabel).disposed(by: disposeBag)
        self.window?.rootViewController?.present(vc, animated: false, completion: nil)
    }

    private func bindViewModel() {
        let info = Observable.combineLatest(currentLabel.asObservable(),
                                            titleTextField.rx.text.orEmpty.distinctUntilChanged(),
                                            descriptionTextView.rx.text.orEmpty.distinctUntilChanged())
        { [weak self] (label, title, description) -> Transaction? in
            guard let transaction = self?.defaultTransaction else { return nil }
            return Transaction(id: transaction.id, label: label.rawValue, title: title,
                               description: description, account: nil, date: nil, price: nil)
        }

        let input = TransactionTableViewCellModel.Input(
            info: editingButton.rx.tap
                .do(afterNext: { [weak self] _ in self?.isEditingMode.toggle() })
                .filter { [weak self] _ in self?.isEditingMode == true }
                .withLatestFrom(info)
                .asDriver(onErrorJustReturn: nil)
                .compactMap { $0 }
        )
        let output = viewModel.transform(input: input)

        output.result.drive(onNext: { [weak self] result in
            guard let self = self else { return }
            if let result = result {
                self.defaultTransaction = result
                return
            }
            self.currentLabel.accept(.init(self.defaultTransaction.label))
            self.titleTextField.text = self.defaultTransaction.title
            self.descriptionTextView.text = self.defaultTransaction.description
        })
        .disposed(by: disposeBag)
    }
}

extension TransactionTableViewCell: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension TransactionTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
