//
//  CollectionView+Extension.swift
//  RxCoreList
//
//  Created by Robert on 8/10/19.
//

public extension UICollectionView {
    func register(cell: CellModel) {
        let type = cell.type
        if let cell = cell as? HeaderFooterModel {
            let position = cell.position
            switch type {
            case .default:
                switch position {
                case .header:
                    register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: cell.reuseIdentifier)
                case .footer:
                    register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: cell.reuseIdentifier)
                }
            case .nib(let nibName, let bundle):
                switch position {
                case .header:
                    register(UINib(nibName: nibName, bundle: bundle), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: cell.reuseIdentifier)
                case .footer:
                    register(UINib(nibName: nibName, bundle: bundle), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: cell.reuseIdentifier)
                }
            case .class(let `class`):
                switch position {
                case .header:
                    register(`class`, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: cell.reuseIdentifier)
                case .footer:
                    register(`class`, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: cell.reuseIdentifier)
                }
            }
        } else {
            switch type {
            case .default:
                register(UICollectionView.self, forCellWithReuseIdentifier: cell.reuseIdentifier)
            case .nib(let nibName, let bundle):
                register(UINib(nibName: nibName, bundle: bundle), forCellWithReuseIdentifier: cell.reuseIdentifier)
            case .class(let `class`):
                register(`class`, forCellWithReuseIdentifier: cell.reuseIdentifier)
            }
        }
    }

    func dequeue<T>(of type: T.Type, fromCellModel cell: CellModel, for indexPath: IndexPath) -> T where T: UICollectionViewCell {
        switch cell.type {
        case .nib(let nibName, _):
            precondition(String(describing: T.self) != nibName, "Cell nib was not registered")
        case .class(let `class`):
            precondition(T.self != `class`.self, "Cell class was not registered")
        case .default:
            precondition(T.self != UICollectionViewCell.self, "Cell class must be equal to UICollectionViewCell")
        }
        return self.dequeueReusableCell(withReuseIdentifier: cell.reuseIdentifier, for: indexPath) as! T
    }

    func dequeue(fromCellModel cell: CellModel, for indexPath: IndexPath) -> UICollectionViewCell {
        self.dequeueReusableCell(withReuseIdentifier: cell.reuseIdentifier, for: indexPath)
    }

    func dequeue<T>(of type: T.Type, fromHeaderFooterModel cell: HeaderFooterModel, for indexPath: IndexPath) -> T where T: UICollectionReusableView {
        switch cell.type {
        case .nib(let nibName, _):
            precondition(String(describing: T.self) != nibName, "Header footer nib was not registered")
        case .class(let `class`):
            precondition(T.self != `class`.self, "Header footer class was not registered")
        case .default:
            precondition(T.self != UICollectionViewCell.self, "Header footer class must be equal to UICollectionReusableView")
        }
        switch cell.position {
        case .header:
            return self.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: cell.reuseIdentifier, for: indexPath) as! T
        case .footer:
            return self.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: cell.reuseIdentifier, for: indexPath) as! T
        }
    }

    func dequeue(fromHeaderFooterModel cell: HeaderFooterModel, for indexPath: IndexPath) -> UICollectionReusableView {
        switch cell.position {
        case .header:
            return self.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: cell.reuseIdentifier, for: indexPath)
        case .footer:
            return self.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: cell.reuseIdentifier, for: indexPath)
        }
    }
}
