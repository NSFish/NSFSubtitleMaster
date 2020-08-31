//
//  main.swift
//  SubtitleMaster
//
//  Created by nsfish on 2020/8/16.
//  Copyright © 2020 nsfish. All rights reserved.
//

import Foundation

enum SubtitleMasterError: Error {
    case notSubtitle
    case dummy
    case illegalShiftSeconds
    case noStyles
    case noEvents
}

if CommandLine.arguments.count > 5 {
    print("Usage: subtitle-master -d <directory path>/<file path> -s <seconds>");
    // subtitle-master -f path/to/directory -s <seconds>
}

var urlString = ""
var stringToFind = ""
var shiftSecondsString = ""
for (index, argument) in CommandLine.arguments.enumerated() {
    if (argument == "-d") {
        urlString = CommandLine.arguments[index + 1]
    }
    else if (argument == "-s") {
        shiftSecondsString = CommandLine.arguments[index + 1]
    }
}

let url = URL(fileURLWithPath: urlString)

do {
    if url.isDirectory {
        let subtitleFiles = try detectSubtitleFilesIn(directory: url)
        if subtitleFiles.count == 0 {
            print("在指定路径下没有找到任何 .ass 文件")
        }
        else {
            try subtitleFiles.forEach {
                print("开始处理 " + $0.lastPathComponent + "...")
                
                if (shiftSecondsString.count > 0) {
                    guard let shiftSeconds = Double.init(shiftSecondsString) else {
                        throw SubtitleMasterError.illegalShiftSeconds
                    }
                    
                    try shiftFile(at: $0, seconds: shiftSeconds)
                }
                else {
                    try organizeAssFile(at: $0)
                }
                
                print("Done.")
            }
        }
    }
    else {
        try SubtitlesMaster.parseFile(at: url)
    }
} catch {
    print("error")
}
