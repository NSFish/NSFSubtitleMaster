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
    case illegalShiftSeconds
    case noStyles
    case noEvents
    case dummy
}

if CommandLine.arguments.count > 5 {
    print("Usage: subtitle-master -d <directory path>/<file path> -s <seconds> -config <directory path>/<config file path>");
}

var urlString = ""
var stringToFind = ""
var shiftSecondsString = ""
var configFilePath = ""
var globalConfigFilePath = ""
for (index, argument) in CommandLine.arguments.enumerated() {
    if (argument == "-d") {
        urlString = CommandLine.arguments[index + 1]
    }
    else if (argument == "-s") {
        shiftSecondsString = CommandLine.arguments[index + 1]
    }
    else if (argument == "-config") {
        configFilePath = CommandLine.arguments[index + 1]
    }
}

let url = URL(fileURLWithPath: urlString)
let configFileURL = URL(fileURLWithPath: configFilePath)

do {
    let config = try Config.init(url: configFileURL)
    
    if url.isDirectory {
        let subtitleFiles = try detectSubtitleFilesIn(directory: url)
        if subtitleFiles.count == 0 {
            print("在指定路径下没有找到任何 .ass 文件")
        }
        else {
            try subtitleFiles.forEach {
                print("开始处理 " + $0.lastPathComponent + "...")
                
                let subtitles = Subtitles.init(url: $0)
                try subtitles.parse()
                subtitles.modifyWith(config: config)
                try subtitles.writeBack()
            }
        }
    }
    else {
        let subtitles = Subtitles.init(url: url)
        try subtitles.parse()
        subtitles.modifyWith(config: config)
        try subtitles.writeBack()
    }
    
    print("Done.")
} catch {
    print("error")
}
