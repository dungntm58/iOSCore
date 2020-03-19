//
//  TableViewDataSource.swift
//  RxCoreList
//
//  Created by Robert Nguyen on 2/8/19.
//  Copyright © 2019 Robert Nguyen. All rights reserved.
//

import DifferenceKit
import RxSwift
import RxCocoa

open class BaseTableViewSource: BaseListViewSource, LoadingAnimatableViewSource, BindableTableViewDataSource {
    private(set) public weak var tableView: UITableView?
    open lazy var disposeBag = DisposeBag()

    private lazy var loadingMoreSection = produceLoadingSection()

    open func getLoadingCellModel() -> CellModel {
        CellModelType.nib(nibName: "LoadingTableViewCell", bundle: Bundle(for: LoadingTableViewCell.classForCoder())).makeCell()
    }

    public func register(in tableView: UITableView) {
        if templateSections.first(where: { $0.cells.isEmpty }) != nil {
            preconditionFailure("There is at least one section register no cell")
        }

        self.tableView = tableView

        if shouldAnimateLoading {
            loadingMoreSection.cells.forEach {
                tableView.register(cell: $0)
            }
        }

        templateSections.forEach {
            if let header = $0.header {
                tableView.register(cell: header)
            }
            if let footer = $0.footer {
                tableView.register(cell: footer)
            }
        }

        templateCells.forEach {
            tableView.register(cell: $0)
        }

        tableView.rx
            .setDataSource(self)
            .disposed(by: disposeBag)
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }

    open func bind(value: ViewModelItem, to cell: UITableViewCell, at indexPath: IndexPath) {}
    open func bindNil(to cell: UITableViewCell, at indexPath: IndexPath) {}
    open func bind(toHeader header: UIView, at section: Int) {}
    open func bind(toFooter footer: UIView, at section: Int) {}
    open func willDisplay(cell: UITableViewCell, at indexPath: IndexPath) {}
    open func reachToEnd() {}

    final override func computedDataSectionsIfAnimating() -> [DataSection] {
        guard shouldAnimateLoading else { return originalDifferenceSections }
        let animatingSection = DataSection(model: originalDifferenceSections.count, elements: isAnimating ? [getLoadingDifferentiable()] : [])
        return originalDifferenceSections + [animatingSection]
    }

    final override func componentReloadData() {
        let dataChangeSet = StagedChangeset(source: differenceSections, target: computedDataSectionsIfAnimating())
        tableView?.reload(using: dataChangeSet,
                          deleteSectionsAnimation: .automatic,
                          insertSectionsAnimation: .automatic,
                          reloadSectionsAnimation: .automatic,
                          deleteRowsAnimation: .automatic,
                          insertRowsAnimation: .automatic,
                          reloadRowsAnimation: .automatic)
        {
            self.differenceSections = $0
        }
    }
}

extension BaseTableViewSource: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        differenceSections.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        differenceSections[section].elements.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel: CellModel
        let item = differenceSections[indexPath.section].elements[indexPath.row]

        if item.base is LoadingDifferentiable {
            cellModel = loadingMoreSection.cells[0]
        } else {
            let lastChangeType = self.lastChangeType
            cellModel = cell(inSection: section(atSection: indexPath.section, onChanged: lastChangeType), row: indexPath.row, onChanged: lastChangeType)
        }
        let cell = tableView.dequeue(fromCellModel: cellModel, for: indexPath)
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

extension BaseTableViewSource: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section >= numberOfDataSections(onChanged: lastChangeType) {
            return loadingMoreSection.cells[0].height
        }
        let lastChangeType = self.lastChangeType
        return cell(inSection: section(atSection: indexPath.section, onChanged: lastChangeType), row: indexPath.row, onChanged: lastChangeType).height
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section >= numberOfDataSections(onChanged: lastChangeType) {
            return loadingMoreSection.cells[0].height
        }
        let lastChangeType = self.lastChangeType
        return cell(inSection: section(atSection: indexPath.section, onChanged: lastChangeType), row: indexPath.row, onChanged: lastChangeType).height
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if section >= numberOfDataSections(onChanged: lastChangeType) {
            return tableView.leastOfHeaderFooterHeight
        }
        return self.section(atSection: section, onChanged: lastChangeType).header?.height ?? tableView.leastOfHeaderFooterHeight
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section >= numberOfDataSections(onChanged: lastChangeType) {
            return tableView.leastOfHeaderFooterHeight
        }
        return self.section(atSection: section, onChanged: lastChangeType).header?.height ?? tableView.leastOfHeaderFooterHeight
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        if section >= numberOfDataSections(onChanged: lastChangeType) {
            return tableView.leastOfHeaderFooterHeight
        }
        return self.section(atSection: section, onChanged: lastChangeType).footer?.height ?? tableView.leastOfHeaderFooterHeight
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section >= numberOfDataSections(onChanged: lastChangeType) {
            return tableView.leastOfHeaderFooterHeight
        }
        return self.section(atSection: section, onChanged: lastChangeType).footer?.height ?? tableView.leastOfHeaderFooterHeight
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section >= numberOfDataSections(onChanged: lastChangeType) {
            return nil
        }
        guard let sectionHeader = self.section(atSection: section, onChanged: lastChangeType).header else {
            return nil
        }
        if let customView = sectionHeader.customView {
            bind(toHeader: customView, at: section)
            return customView
        }
        if let header = tableView.dequeue(fromHeaderFooterModel: sectionHeader) {
            bind(toHeader: header, at: section)
            return header
        }
        return nil
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section >= numberOfDataSections(onChanged: lastChangeType) {
            return nil
        }
        guard let sectionFooter = self.section(atSection: section, onChanged: lastChangeType).footer else {
            return nil
        }
        if let customView = sectionFooter.customView {
            bind(toFooter: customView, at: section)
            return customView
        }
        if let footer = tableView.dequeue(fromHeaderFooterModel: sectionFooter) {
            bind(toFooter: footer, at: section)
        }
        return nil
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        willDisplay(cell: cell, at: indexPath)
        if shouldAnimateLoading {
            guard let cell = cell as? LoadingAnimatable else {
                return
            }
            cell.startAnimation()
            reachToEnd()
        } else if indexPath.section == numberOfDataSections(onChanged: lastChangeType) - 1, indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            reachToEnd()
        }
    }
}

private extension BaseTableViewSource {
    func produceLoadingSection() -> SectionModel {
        let cell = getLoadingCellModel()
        return InternalSectionModel(cells: [cell])
    }
}
