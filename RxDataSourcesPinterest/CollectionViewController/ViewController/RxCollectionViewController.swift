//
//  RxCollectionViewController.swift
//  RxDataSourcesPinterest
//
//  Created by sakiyamaK on 2019/12/08.
//  Copyright © 2019 sakiyamaK. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class RxCollectionViewController: UIViewController {

    typealias Cell = RxCollectionViewCell
    private let CELL_CLASS = Cell.self
    private let CELL_ID = NSStringFromClass(Cell.self)

    private let viewModel = RxCollectionViewModel()
    private let disposeBag = DisposeBag()

    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!

    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            guard let nibName = NSStringFromClass(CELL_CLASS).components(separatedBy: ".").last else{return}
            collectionView.register(UINib(nibName: nibName, bundle: nil), forCellWithReuseIdentifier: CELL_ID)
            if let layout = collectionView.collectionViewLayout as? PinterestLayout {
                layout.delegate = self
            }
        }
    }

    lazy var dataSource = RxCollectionViewSectionedAnimatedDataSource<RxCollectionViewModel.SectionModel>.init(
        animationConfiguration: AnimationConfiguration(insertAnimation: .fade, reloadAnimation: .none, deleteAnimation: .fade),
        configureCell:{[weak self] (dataSource, collectionView, indexPath, item) -> UICollectionViewCell in
            guard
                let wSelf = self,
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: wSelf.CELL_ID, for: indexPath) as? Cell else {
                    return UICollectionViewCell()
            }
            cell.configCell(text: item.name, urlStr: item.urlStr)
            return cell
    })


    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.rx.setDelegate(self).disposed(by: self.disposeBag)

        viewModel.dataObservable.bind(to: collectionView.rx.items(dataSource: dataSource)).disposed(by: self.disposeBag)

        viewModel.dataObservable.subscribe(onNext: {[weak self] (data) in
            self?.button2.isEnabled = (data.first?.items.count ?? 0) != 0
        }).disposed(by: self.disposeBag)

        button1.rx.tap.asDriver().drive(onNext: {[weak self] (_) in
            self?.viewModel.add()
        }).disposed(by: disposeBag)

        button2.rx.tap.asDriver().drive(onNext: {[weak self] (_) in
            self?.viewModel.remove()
        }).disposed(by: disposeBag)
    }
}

extension RxCollectionViewController: UICollectionViewDelegate {
}


extension RxCollectionViewController:PinterestLayoutDelegate{

    //セルの高さを返す
    func cellHeight(collectionView: UICollectionView, indexPath: IndexPath, cellWidth: CGFloat) -> CGFloat {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_ID, for: indexPath) as? Cell else{
            return 0
        }

        let item = dataSource[indexPath]

        //この時点でsetNeedsLayout(), layoutIfNeeded()しても高さが求められないので専用メソッドを呼ぶ
        cell.configCell(text: item.name, urlStr: item.urlStr)
        let h = cell.height(cellWidth: cellWidth)

        return h
    }
}


