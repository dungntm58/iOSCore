//
//  CollectionViewDataSource.swift
//  CoreCleanSwiftList
//
//  Created by Robert Nguyen on 2/8/19.
//  Copyright © 2019 Robert Nguyen. All rights reserved.
//

import RxSwift
import RxCocoa
import DifferenceKit

open class BaseCollectionViewSource: BaseListViewSource, LoadingAnimatableViewSource, BindableCollectionViewDataSource {
    private(set) public weak var collectionView: UICollectionView?

    private lazy var loadingCell: CellModel = {
        return getLoadingCellModel()
    }()

    open func getLoadingCellModel() -> CellModel {
        return CellModelType.nib(nibName: "LoadingCollectionViewCell", bundle: Bundle(for: LoadingCollectionViewCell.classForCoder())).toCellModel()
    }

    public func register(in collectionView: UICollectionView) {
        if sections.first(where: { $0.cells.isEmpty }) != nil {
            fatalError("There is at least one section register no cell")
        }

        self.collectionView = collectionView

        if shouldAnimateLoading {
            collectionView.register(cell: loadingCell)
        }

        sections.forEach {
            if let header = $0.header {
                collectionView.register(cell: header)
            }
            if let footer = $0.footer {
                collectionView.register(cell: footer)
            }
        }

        registrationCells.forEach {
            collectionView.register(cell: $0)
        }

        let differentiableDataSource: DifferentiableSectionedCollectionViewDataSource<DataSection> =  DifferentiableSectionedCollectionViewDataSource<DataSection>(configureCell: configureCell)
        collectionView.rx
            .items(dataSource: differentiableDataSource)(differenceSectionsRelay)
            .disposed(by: disposeBag)

        collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }

    open func bind(value: CleanViewModelItem, to cell: UICollectionViewCell, at indexPath: IndexPath) {}
    open func bindNil(to cell: UICollectionViewCell, at indexPath: IndexPath) {}
    open func bind(toHeader header: UICollectionReusableView, at section: Int) {}
    open func bind(toFooter footer: UICollectionReusableView, at section: Int) {}

    override func toDataSectionWhenLoadingChanged(from: ([DataSection], Bool)) -> [DataSection] {
        let (sections, isLoading) = from
        guard shouldAnimateLoading && isLoading && sections.count > 0 else {
            return sections
        }

        var newSections = sections
        newSections[newSections.count - 1].elements.append(getLoadingDifferentiable())
        return newSections
    }
}

extension BaseCollectionViewSource {
    func configureCell(dataSource: DifferentiableSectionedCollectionViewDataSource<DataSection>, collectionView: UICollectionView, indexPath: IndexPath, item: AnyDifferentiable) -> UICollectionViewCell {
        let cellModel: CellModel

        if item.base is LoadingDifferentiable {
            cellModel = loadingCell
        } else {
            cellModel = cell(at: indexPath)
        }

        let cell = collectionView.dequeue(fromCellModel: cellModel, for: indexPath)
        switch cell {
        case _ as LoadingAnimatable:
            break
        default:
            if let value = item.base as? CleanViewModelItem {
                bind(value: value, to: cell, at: indexPath)
            } else {
                bindNil(to: cell, at: indexPath)
            }
        }

        return cell
    }
}

extension BaseCollectionViewSource: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            if let header = sections[indexPath.section].header {
                let headerCell = collectionView.dequeue(fromHeaderFooterModel: header, for: indexPath)
                bind(toHeader: headerCell, at: indexPath.section)
                return headerCell
            }
        case UICollectionView.elementKindSectionFooter:
            if let footer = sections[indexPath.section].footer {
                let footerCell = collectionView.dequeue(fromHeaderFooterModel: footer, for: indexPath)
                bind(toFooter: footerCell, at: indexPath.section)
                return footerCell
            }
        default:
            break
        }

        return UICollectionReusableView(frame: .zero)
    }
}
