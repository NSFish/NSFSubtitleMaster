//
//  URL+Extension.swift
//  SubtitleMaster
//
//  Created by nsfish on 2020/8/16.
//

import Foundation

// https://stackoverflow.com/a/43575761
extension URL {
    var isDirectory: Bool {
        let values = try? resourceValues(forKeys: [.isDirectoryKey])
        return values?.isDirectory ?? false
    }
}
