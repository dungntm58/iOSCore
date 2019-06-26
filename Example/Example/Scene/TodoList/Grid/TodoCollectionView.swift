//
//  TodoCollectionView.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 1/23/19.
//  Copyright © 2019 Robert Nguyễn. All rights reserved.
//

import RxSwift
import CoreList
import CoreBase
import Toaster

class TodoCollectionView: BaseCollectionView, Appearant {
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configure()
    }
    
    func willAppear() {
        self.viewSource = TodoList2ViewSource(store: store)
    }
    
    func configure() {
    }
    
    var store: TodoStore? {
        return (viewController as? TodoList2ViewController)?.scene?.store
    }
}
