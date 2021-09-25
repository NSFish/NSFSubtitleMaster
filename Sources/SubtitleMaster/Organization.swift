//
//  Orgenization.swift
//  SubtitleMaster
//
//  Created by nsfish on 2020/8/16.
//

import Foundation
import OpenCC

func detectSubtitleFilesIn(directory: URL) throws -> [URL] {
    let items = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: .none, options: .skipsHiddenFiles)
    let subtitleFiles = items.filter { $0.pathExtension.lowercased() == "ass" }.sorted { $0.lastPathComponent < $1.lastPathComponent }
    
    return subtitleFiles
}
