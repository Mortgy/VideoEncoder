//
//  URL.swift
//  VideoEncoder
//
//  Created by Mortgy on 4/15/21.
//

import Foundation

extension URL {
    static func temporaryExportURL() -> URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let filename = ProcessInfo.processInfo.globallyUniqueString + ".mp4"
        return documentDirectory.appendingPathComponent(filename)
    }
}
