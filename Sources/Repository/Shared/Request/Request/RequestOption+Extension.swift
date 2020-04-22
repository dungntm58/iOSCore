//
//  RequestOption+Extension.swift
//  CoreRequest
//
//  Created by Robert on 8/10/19.
//

public extension ProgressTrackable {
    var queue: DispatchQueue { .main }
}

public extension TrackingOption where Self: ProgressTrackable {
    var tracking: ProgressTrackable? { self }
}

public extension DownloadRequestOption where Self: DownloadFileDestination {
    var downloadFileDestination: DownloadFileDestination? { self }
}
