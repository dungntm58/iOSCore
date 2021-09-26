//
//  RequestOption+Extension.swift
//  CoreRequest
//
//  Created by Robert on 8/10/19.
//

import Foundation

extension ProgressTrackable {
    @inlinable
    public var queue: DispatchQueue { .main }
}

extension TrackingOption where Self: ProgressTrackable {
    @inlinable
    public var tracking: ProgressTrackable? { self }
}

extension DownloadRequestOption where Self: DownloadFileDestination {
    @inlinable
    public var downloadFileDestination: DownloadFileDestination? { self }
}
