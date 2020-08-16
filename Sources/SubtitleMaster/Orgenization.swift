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
    let subtitleFiles = items.filter { url -> Bool in
        return url.pathExtension.lowercased() == "ass"
    }
    
    return subtitleFiles
}

func orgenizeAssFile(at url: URL) throws {
    let subtitle = try String(contentsOf: url)
    // 文件中的换行符有的是 \r\n，有的只有 \n，提前做个统一处理
    let lines = subtitle.replacingOccurrences(of: "\r\n", with: "\n")
        .replacingOccurrences(of: "\n", with: "\r\n")
        .components(separatedBy: "\r\n")
    
    // TODO: 去除 V4+ Styles 中的 STAFF
    // 可以在下面提到的 subtitle_config 中加入一个 remove_staff 的标志来决定是否删除
    let dialogueLines = lines.filter { $0.hasPrefix("Dialogue:") && !$0.contains("STAFF") }
    let firstDialogueIndex = lines.firstIndex(of: dialogueLines.first!)!
    let nonDialogueLines = lines[0..<firstDialogueIndex]
    
    let mainDialogueLines = dialogueLines.filter { !$0.contains(",JP,") }
    let secondLanguageDialogueLines = dialogueLines.filter { $0.contains(",JP,") }
    
    let mainDialogues = mainDialogueLines.map { Dialogue(eventLine: $0) }
    
    // TODO: 可以构造一个配置文件，比如 subtitle_config
    // 里面指定需要留下的 style，以及 style 的顺序，然后这里读取
    // 以金田一少年事件簿 R 为例
    // CN
    // OP
    // CN
    // OP?
    // ED
    // CN
    var OPStart: String?
    var OPEnd: String?
    var EDStart: String?
    var EDEnd: String?
    
    var previousDialogue: Dialogue?
    for (index, dialogue) in mainDialogues.enumerated() {
        if dialogue.style == "OP" {
            if OPStart == nil {
                OPStart = dialogue.start
            }
        }
        else if dialogue.style == "ED" {
            if EDStart == nil {
                EDStart = dialogue.start
            }
            else if index == mainDialogues.count - 1 {
                // 如果 ED 之后就没有内容了，下面的判定就会落空
                // 这里就把最后一行作为 ED
                EDEnd = dialogue.start
            }
        }
        else if let previousDialogue = previousDialogue {
            // 如果当前行的 style 不是 OP，而上一行是，则上一行很可能就是 OPEnd
            // 之所以不说死，是因为同一个 style 很可能会被用于 OP 外的其他地方
            // 比如金田一少年事件簿 R 中，用在了人名上
            // 所以 OP 结尾的判定还要算上 OPEnd == nil
            if OPEnd == nil
                && previousDialogue.style == "OP" {
                OPEnd = previousDialogue.start
            }
            
            // ED 同理
            if EDEnd == nil
                && previousDialogue.style == "ED" {
                EDEnd = previousDialogue.start
            }
        }
        
        previousDialogue = dialogue
    }
    
    let prologue = mainDialogues.filter { $0.start < OPStart! }
    let OP = mainDialogues.filter { $0.start >= OPStart! && $0.start <= OPEnd! }
    let content = mainDialogues.filter { $0.start > OPEnd! && $0.start < EDStart! }
    let ED = mainDialogues.filter { $0.start >= EDStart! && $0.start <= EDEnd! }
    let nextEpisodePreview = mainDialogues.filter { $0.start > EDEnd! }
    
    let orgenizedDialogues = [Comment(content: "Prologue")] + prologue
        + [Comment(content: "OP")] + OP
        + [Comment(content: "正片")] + content
        + [Comment(content: "ED")] + ED
        + [Comment(content: "下集预告")] + nextEpisodePreview
        + [Comment(content: "JP")]
    
    let bundleURL = URL.init(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/Github/SwiftyOpenCC/OpenCCDictionary.bundle")
    let bundle = Bundle.init(url: bundleURL)!
    let converter = try! ChineseConverter(bundle: bundle, option: [.simplify, .TWStandard, .TWIdiom])
    orgenizedDialogues.forEach { dialogue in
        dialogue.text = converter.convert(dialogue.text)
    }
    let orgenizedDialogueLines = orgenizedDialogues.map { $0.line() } + secondLanguageDialogueLines
    
    let OrgenizedLines = nonDialogueLines + orgenizedDialogueLines
    
    let result = OrgenizedLines.joined(separator: "\r\n")
    let newFileName = url.deletingPathExtension().appendingPathExtension("new").appendingPathExtension(url.pathExtension).lastPathComponent
    let fileURL = url.deletingLastPathComponent().appendingPathComponent(newFileName)
    try result.write(to: fileURL, atomically: false, encoding: .utf8)
}
