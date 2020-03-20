//
//  LoadingTableViewCell.swift
//  CoreList
//
//  Created by Robert on 2/12/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

public class LoadingTableViewCell: UITableViewCell, LoadingAnimatable {
    @IBOutlet weak var activityView: UIActivityIndicatorView!

    public func startAnimation() {
        activityView.startAnimating()
    }

    public func stopAnimation() {
        activityView.stopAnimating()
    }
}
