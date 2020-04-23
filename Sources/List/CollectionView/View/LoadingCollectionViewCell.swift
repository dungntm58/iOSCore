//
//  LoadingCollectionViewCell.swift
//  CoreList
//
//  Created by Robert on 3/27/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

public class LoadingCollectionViewCell: UICollectionViewCell, LoadingAnimatable {
    @IBOutlet weak var activityView: UIActivityIndicatorView!

    public func startAnimation() {
        activityView.startAnimating()
    }

    public func stopAnimation() {
        activityView.stopAnimating()
    }
}
