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
}

if CommandLine.arguments.count > 3 {
    print("Usage: subtitle-master -f");
}

var urlString = "", stringToFind = ""
for (index, argument) in CommandLine.arguments.enumerated() {
    if (argument == "-d") {
        urlString = CommandLine.arguments[index + 1]
    }
    else if (argument == "-f") {
        urlString = CommandLine.arguments[index + 1]
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
            try subtitleFiles.forEach { try orgenizeAssFile(at: $0) }
        }
    }
    else {
        try orgenizeAssFile(at: url)
    }
} catch {
    print("error")
}
