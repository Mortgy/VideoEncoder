//
//  EncoderModel.swift
//  VideoEncoderExample
//
//  Created by Mortgy on 4/27/21.
//

import Foundation
import AVFoundation

struct EncoderModel {
    var videoAssetUrl: URL
    var videoAsset: AVAsset {
        AVAsset(url: videoAssetUrl)
    }
}
