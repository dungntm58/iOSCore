//
//  UICollectionViewDecorativeLayout.swift
//  CoreList
//
//  Created by Robert on 04/03/2021.
//

import UIKit

@objc public protocol UICollectionViewDelegateDecorativeLayout: UICollectionViewDelegateFlowLayout {
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewDecorativeFlowLayout, viewForDecorationElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewDecorativeFlowLayout, referenceSizeForDecorationInSection section: Int) -> CGSize
}

extension UICollectionView {
    public static let elementKindSectionDecoration = "UICollectionViewElementKindSectionDecoration"
}

open class UICollectionViewDecorativeFlowLayout: UICollectionViewFlowLayout {
    var delegate: UICollectionViewDelegateDecorativeLayout? {
        self.collectionView?.delegate as? UICollectionViewDelegateDecorativeLayout
    }

    open override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let superAttributes = super.layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath)
        guard let collectionView = collectionView,
              let attributes = superAttributes
        else { return superAttributes }
        let decorationAttributesSize: CGSize
        if let size = delegate?.collectionView?(collectionView, layout: self, referenceSizeForDecorationInSection: attributes.indexPath.section) {
            decorationAttributesSize = size
        } else {
            let tmpWidth = collectionView.contentSize.width
            let tmpHeight = self.itemSize.height + self.minimumLineSpacing + self.sectionInset.top / 2 + self.sectionInset.bottom / 2  // or attributes.frame.size.height instead of itemSize.height if dynamic or recalculated
            decorationAttributesSize = CGSize(width: tmpWidth, height: tmpHeight)
        }
        attributes.frame = CGRect(x: 0, y: attributes.frame.origin.y - self.sectionInset.top, width: decorationAttributesSize.width, height: decorationAttributesSize.height)
        return attributes
    }
}
