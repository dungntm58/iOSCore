//
//  ListViewSourceModel.swift
//  CoreCleanSwiftList
//
//  Created by Robert Nguyen on 1/13/19.
//  Copyright © 2019 Robert Nguyen. All rights reserved.
//

import DifferenceKit
import RxSwift
import RxRelay

extension Int: Differentiable {}
extension Differentiable {
    public func toAnyDifferentiable() -> AnyDifferentiable {
        return AnyDifferentiable(self)
    }
}

public typealias DataSection = ArraySection<Int, AnyDifferentiable>

open class BaseListViewSource: NSObject, ListViewSource {
    private var listModels: [String: [CleanViewModelItem]]
    private(set) public lazy var disposeBag = DisposeBag()

    lazy var disposables = CompositeDisposable()
    lazy var registrationCells: [CellModel] = {
        return produceCells()
    }()
    let sectionsRelay: BehaviorRelay<[SectionModel]>
    let originalDifferenceSectionsRelay: PublishRelay<[DataSection]>
    let differenceSectionsRelay: PublishRelay<[DataSection]>

    public let isLoadingRelay: BehaviorRelay<Bool>
    public let modelRelay: PublishRelay<ListViewSourceModel>

    open var shouldAnimateLoading: Bool

    public init(sections: [SectionModel], shouldAnimateLoading: Bool = true, initialModel: [ListViewSourceModel] = []) {
        self.isLoadingRelay = BehaviorRelay(value: false)
        self.modelRelay = PublishRelay()
        self.shouldAnimateLoading = shouldAnimateLoading
        self.listModels = [:]

        // Set up first differenceSections
        for (index, section) in sections.enumerated() {
            section.tag = index
        }

        self.sectionsRelay = BehaviorRelay(value: sections)
        self.originalDifferenceSectionsRelay = PublishRelay()
        self.differenceSectionsRelay = PublishRelay()

        super.init()

        configure()

        if initialModel.contains(where: { $0.needsReload }) {
            #if DEBUG
            Swift.print("Animation effect will not perform")
            #endif
            let disabledReloadModel = initialModel.map {
                ListViewSourceModel(type: $0.type, data: $0.data, needsReload: false, identifier: $0.identifier)
            }
            Observable.from(disabledReloadModel).bind(to: modelRelay).disposed(by: disposeBag)
        } else {
            Observable.from(initialModel).bind(to: modelRelay).disposed(by: disposeBag)
        }
    }

    public var isLoading: Bool {
        return isLoadingRelay.value
    }

    public var sections: [SectionModel] {
        return sectionsRelay.value
    }

    public var cells: [CellModel] {
        return registrationCells
    }

    public func models(forIdentifier identifier: String) -> [CleanViewModelItem]? {
        return listModels[identifier]
    }

    open func cell(at indexPath: IndexPath) -> CellModel {
        return sections[indexPath.section].cells[0]
    }

    open func objects(in section: SectionModel, at index: Int, onChanged type: ListModelChangeType) -> [AnyDifferentiable] {
        return []
    }

    public func add(sections: [SectionModel]) {
        var newSections = self.sections
        newSections.append(contentsOf: sections)
        sectionsRelay.accept(newSections)
    }

    public func removeSection(at index: Int) {
        var newSections = self.sections
        newSections.remove(at: index)
        sectionsRelay.accept(newSections)
    }

    func toDataSectionWhenLoadingChanged(from: ([DataSection], Bool)) -> [DataSection] {
        fatalError()
    }
}

private extension BaseListViewSource {
    func produceCells() -> [CellModel] {
        let allCells = sections.flatMap { $0.cells }
        let uniqueCells = Dictionary(grouping: allCells, by: { $0.reuseIdentifier }).map { $0.value }.compactMap { $0.first }
        if allCells.count != uniqueCells.count {
            Swift.print("More than two different cells have the same reuse identifier, the first found one has been selected")
        }

        return uniqueCells
    }

    func configure() {
        _ = disposables.insert(
            Observable
                .combineLatest(
                    originalDifferenceSectionsRelay,
                    isLoadingRelay
                ) { ($0, $1) }
                .map(toDataSectionWhenLoadingChanged)
                .bind(to: differenceSectionsRelay)
        )
        _ = disposables.insert(
            modelRelay
                .do(onNext: updateModel)
                .filter { $0.needsReload }
                .map { $0.type }
                .withLatestFrom(sectionsRelay) { ($1, $0) }
                .map(toDataSectionWhenModelChanged)
                .bind(to: originalDifferenceSectionsRelay)
        )
        _ = disposables.insert(
            sectionsRelay
                .do(onNext: {
                    sections in
                    for (index, section) in sections.enumerated() {
                        section.tag = index
                    }
                })
                .map { ($0, ListModelChangeType.initial) }
                .map(toDataSectionWhenModelChanged)
                .bind(to: originalDifferenceSectionsRelay)
        )
        disposables.disposed(by: disposeBag)
    }

    func updateModel(_ model: ListViewSourceModel) {
        let modelArray: [CleanViewModelItem] = model.data.compactMap { $0 as? CleanViewModelItem }
        let identifier = model.identifier

        guard var models = listModels[identifier] else {
            listModels[identifier] = modelArray
            return
        }

        switch model.type {
        case .initial, .swap:
            models = modelArray
        case .addNew(let position):
            switch position {
            case .begin:
                models.insert(contentsOf: modelArray, at: 0)
            case .end:
                models.append(contentsOf: modelArray)
            case .middle(let start, _):
                models.insert(contentsOf: modelArray, at: start)
            }
        case .remove(let position):
            switch position {
            case .begin:
                models.removeFirst()
            case .end:
                models.removeLast()
            case .middle(let start, let length):
                guard length > 0 else {
                    return
                }
                let end = min(start + length - 1, models.count - 1)
                models.removeSubrange(start...end)
            }
        case .replace(let start, let length):
            guard length > 0 else {
                return
            }
            let end = start + length - 1
            models.replaceSubrange(start...end, with: modelArray)
        }

        listModels[identifier] = models
    }

    func toDataSectionWhenModelChanged(from: ([SectionModel], ListModelChangeType)) -> [DataSection] {
        let (sections, type) = from
        return sections
            .enumerated()
            .map ({
                enumeration -> DataSection in
                return DataSection(model: enumeration.element.tag, elements: objects(in: enumeration.element, at: enumeration.offset, onChanged: type))
            })
    }
}
