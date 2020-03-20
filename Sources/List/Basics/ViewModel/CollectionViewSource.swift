//
//  CollectionViewDataSource.swift
//  RxCoreList
//
//  Created by Robert Nguyen on 2/8/19.
//  Copyright © 2019 Robert Nguyen. All rights reserved.
//

import DifferenceKit
import Combine

open class BaseCollectionViewSource: BaseListViewSource, LoadingAnimatableViewSource, BindableCollectionViewDataSource {
    private(set) public weak var collectionView: UICollectionView?

    private lazy var loadingCell = getLoadingCellModel()

    open func getLoadingCellModel() -> CellModel {
        CellModelType.nib(nibName: "LoadingCollectionViewCell", bundle: Bundle(for: LoadingCollectionViewCell.classForCoder())).makeCell()
    }

    final public func register(in collectionView: UICollectionView) {
        if templateSections.first(where: { $0.cells.isEmpty }) != nil {
            preconditionFailure("There is at least one section register no cell")
        }

        self.collectionView = collectionView

        if shouldAnimateLoading {
            collectionView.register(cell: loadingCell)
        }

        templateSections.forEach {
            if let header = $0.header {
                collectionView.register(cell: header)
            }
            if let footer = $0.footer {
                collectionView.register(cell: footer)
            }
        }

        templateCells.forEach {
            collectionView.register(cell: $0)
        }

        collectionView.dataSource = self
        collectionView.delegate = self
    }

    open func bind(value: ViewModelItem, to cell: UICollectionViewCell, at indexPath: IndexPath) {}
    open func bindNil(to cell: UICollectionViewCell, at indexPath: IndexPath) {}
    open func bind(toHeader header: UICollectionReusableView, at section: Int) {}
    open func bind(toFooter footer: UICollectionReusableView, at section: Int) {}
    open func willDisplay(cell: UICollectionViewCell, at indexPath: IndexPath) {}
    open func reachToEnd() {}

    final override func computedDataSectionsIfAnimating() -> [DataSection] {
        guard shouldAnimateLoading && isAnimating else {
            return originalDifferenceSections
        }
        var differenceSections = originalDifferenceSections
        if differenceSections.isEmpty {
            differenceSections.append(DataSection(model: 0, elements: [getLoadingDifferentiable()]))
        } else {
            differenceSections[originalDifferenceSections.count - 1].elements.append(getLoadingDifferentiable())
        }
        return differenceSections
    }

    final override func componentReloadData() {
        let dataChangeSet = StagedChangeset(source: differenceSections, target: computedDataSectionsIfAnimating())
        collectionView?.reload(using: dataChangeSet, setData: {
            data in
            self.differenceSections = data
        })
    }
}

extension BaseCollectionViewSource: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        differenceSections.count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        differenceSections[section].elements.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellModel: CellModel
        let item = differenceSections[indexPath.section].elements[indexPath.row]

        if item.base is LoadingDifferentiable {
            cellModel = loadingCell
        } else {
            let lastChangeType = self.lastChangeType
            cellModel = cell(inSection: section(atSection: indexPath.section, onChanged: lastChangeType), row: indexPath.row, onChanged: lastChangeType)
        }

        let cell = collectionView.dequeue(fromCellModel: cellModel, for: indexPath)
        switch cell {
        case _ as LoadingAnimatable:
            break
        default:
            if let value = item.base as? ViewModelItem {
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
            if let header = section(atSection: indexPath.section, onChanged: lastChangeType).header {
                let headerCell = collectionView.dequeue(fromHeaderFooterModel: header, for: indexPath)
                bind(toHeader: headerCell, at: indexPath.section)
                return headerCell
            }
        case UICollectionView.elementKindSectionFooter:
            if let footer = section(atSection: indexPath.section, onChanged: lastChangeType).footer {
                let footerCell = collectionView.dequeue(fromHeaderFooterModel: footer, for: indexPath)
                bind(toFooter: footerCell, at: indexPath.section)
                return footerCell
            }
        default:
            break
        }
        return .init(frame: .zero)
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        willDisplay(cell: cell, at: indexPath)
        if shouldAnimateLoading {
            guard let cell = cell as? LoadingAnimatable else {
                return
            }
            cell.startAnimation()
            reachToEnd()
        } else if indexPath.section == numberOfDataSections(onChanged: lastChangeType) - 1, indexPath.row == collectionView.numberOfItems(inSection: indexPath.section) - 1 {
            reachToEnd()
        }
    }
}
