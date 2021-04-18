//
//  ExportConfiguration.swift
//  VideoEncoder
//
//  Created by Mortgy on 4/15/21.
//

import Foundation
import AVFoundation

struct ExportConfiguration {
    var outputURL = URL.temporaryExportURL()
    var fileType: AVFileType = .mp4
    var shouldOptimizeForNetworkUse = false
    var metadata: [AVMetadataItem] = []
}
