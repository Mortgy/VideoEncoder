//
//  ExportConfiguration.swift
//  VideoEncoder
//
//  Created by Mortgy on 4/15/21.
//

import Foundation
import AVFoundation

public struct ExportConfiguration {
    public var outputURL: URL
    public var fileType: AVFileType
    public var shouldOptimizeForNetworkUse: Bool
    public var metadata: [AVMetadataItem]
    
    public init(outputURL: URL = URL.temporaryExportURL(), fileType: AVFileType = .mp4, shouldOptimizeForNetworkUse: Bool = false, metadata: [AVMetadataItem] = []) {
        self.outputURL = outputURL
        self.fileType = fileType
        self.shouldOptimizeForNetworkUse = shouldOptimizeForNetworkUse
        self.metadata = metadata
    }
}
