//
//  Print.swift
//  VideoEncoder
//
//  Created by Mortgy on 4/16/21.
//

import Foundation

func printDebug(_ items: Any..., separator: String = " ", terminator: String = "\n", fileName: String = #file,
                functionName: String = #function,
                lineNumber: Int = #line,
                columnNumber: Int = #column) {
    #if DEBUG
    print("\(items)\n Called by \(fileName) - \(functionName) at line \(lineNumber)[\(columnNumber)]", separator: separator, terminator: terminator)
    #endif
}
