//
//  LabelPicker.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/14.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

final class LabelPickerViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let selectedLabel = PublishRelay<Label>()

    private let disposeBag = DisposeBag()
    private lazy var labels: [Label] = {
        var result = [Label]()
        for i in 0..<10 {
            result.append(Label(i))
        }
        return result
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.layer.cornerRadius = 16

        collectionView.rx.itemSelected
            .compactMap { [weak self] in self?.labels[$0.row] }
            .do(afterNext: { [weak self] _ in self?.dismiss(animated: true, completion: nil) })
            .bind(to: selectedLabel)
            .disposed(by: disposeBag)

        Observable.just(labels)
            .bind(to: collectionView.rx.items(cellIdentifier: Identifier.labelCell,
                                              cellType: LabelCollectionViewCell.self)) { $2.setup($1) }
            .disposed(by: disposeBag)
    }
}
