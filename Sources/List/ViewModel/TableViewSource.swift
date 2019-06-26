//
//  TableViewDataSource.swift
//  CoreCleanSwiftList
//
//  Created by Robert Nguyen on 2/8/19.
//  Copyright © 2019 Robert Nguyen. All rights reserved.
//

import DifferenceKit
import RxSwift
import RxCocoa

open class BaseTableViewSource: BaseListViewSource, LoadingAnimatableViewSource, BindableTableViewDataSource {
    private(set) public weak var tableView: UITableView?

    private lazy var loadingMoreSection: SectionModel = {
        return produceLoadingSection()
    }()

    open func getLoadingCellModel() -> CellModel {
        return CellModelType.nib(nibName: "LoadingTableViewCell", bundle: Bundle(for: LoadingTableViewCell.classForCoder())).toCellModel()
    }

    public func register(in tableView: UITableView) {
        if sections.first(where: { $0.cells.isEmpty }) != nil {
            fatalError("There is at least one section register no cell")
        }

        self.tableView = tableView

        if shouldAnimateLoading {
            loadingMoreSection.cells.forEach {
                tableView.register(cell: $0)
            }
        }

        sections.forEach {
            if let header = $0.header {
                tableView.register(cell: header)
            }
            if let footer = $0.footer {
                tableView.register(cell: footer)
            }
        }

        registrationCells.forEach {
            tableView.register(cell: $0)
        }

        let differentiableDataSource: DifferentiableSectionedTableViewDataSource<DataSection> =  DifferentiableSectionedTableViewDataSource<DataSection>(configureCell: configureCell)
        tableView.rx
            .items(dataSource: differentiableDataSource)(differenceSectionsRelay)
            .disposed(by: disposeBag)

        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }

    open func bind(value: CleanViewModelItem, to cell: UITableViewCell, at indexPath: IndexPath) {}
    open func bindNil(to cell: UITableViewCell, at indexPath: IndexPath) {}
    open func bind(toHeader header: UIView, at section: Int) {}
    open func bind(toFooter footer: UIView, at section: Int) {}

    override func toDataSectionWhenLoadingChanged(from: ([DataSection], Bool)) -> [DataSection] {
        let (sections, isLoading) = from
        guard shouldAnimateLoading else {
            return sections
        }

        var newSections = sections
        newSections.append(DataSection(model: -1, elements: isLoading ? [getLoadingDifferentiable()] : []))
        return newSections
    }
}

extension BaseTableViewSource {
    func configureCell(dataSource: DifferentiableSectionedTableViewDataSource<DataSection>, tableView: UITableView, indexPath: IndexPath, item: AnyDifferentiable) -> UITableViewCell {
        let cellModel: CellModel

        if item.base is LoadingDifferentiable {
            cellModel = loadingMoreSection.cells[0]
        } else {
            cellModel = cell(at: indexPath)
        }
        let cell = tableView.dequeue(fromCellModel: cellModel, for: indexPath)
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

extension BaseTableViewSource: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section >= sections.count {
            return loadingMoreSection.cells[0].height
        }
        return cell(at: indexPath).height
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section >= sections.count {
            return loadingMoreSection.cells[0].height
        }
        return cell(at: indexPath).height
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section >= sections.count {
            return 0
        }
        return sections[section].header?.height ?? 0
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section >= sections.count {
            return 0
        }
        return sections[section].footer?.height ?? 0
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section >= sections.count {
            return nil
        }

        guard let sectionHeader = sections[section].header else {
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
        if section >= sections.count {
            return nil
        }

        guard let sectionFooter = sections[section].footer else {
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
}

private extension BaseTableViewSource {
    func produceLoadingSection() -> SectionModel {
        let cell = getLoadingCellModel()
        let section = DefaultSectionModel(cells: [cell])
        return section
    }
}
