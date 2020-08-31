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

func organizeAssFile(at url: URL) throws {
    let subtitle = try String(contentsOf: url)
    // 文件中的换行符有的是 \r\n，有的只有 \n，提前做个统一处理
    let lines = subtitle.replacingOccurrences(of: "\r\n", with: "\n")
        .replacingOccurrences(of: "\n", with: "\r\n")
        .components(separatedBy: "\r\n")
    
    // TODO: 去除 V4+ Styles 中的 STAFF
    // 可以在下面提到的 subtitle_config 中加入一个 remove_staff 的标志来决定是否删除
    let dialogueLines = lines.filter {
        return $0.hasPrefix("Dialogue:")
            && !$0.contains("STAFF")
    }
    let firstDialogueIndex = lines.firstIndex(of: dialogueLines.first!)!
    // 清除掉注释（通常是字幕组的出品文案）原有的 Comment
    let nonDialogueLines = lines[0..<firstDialogueIndex].filter {
        return !$0.contains("Comment: ")
            && !$0.hasPrefix(";")
    }
    
    // TODO: 清除多余的空行
    let mainDialogueLines = dialogueLines.filter {
        return !$0.contains(",JP,")
            && !$0.contains(",JP(UP),")
    }
    
    // 第二语言如果也有不同部分，比如金田一中的 JP 和 JP(UP)
    // 则集成在一起后需要按开始时间排个序
    var secondLanguageDialogueLines = dialogueLines.filter {
        return $0.contains(",JP,")
            || $0.contains(",JP(UP),")
    }
    var secondLanguageDialogues = secondLanguageDialogueLines.map { Dialogue(eventLine: $0) }
        .filter( { $0.text.count > 0} )
    secondLanguageDialogues.sort { $0.start < $1.start }
    secondLanguageDialogueLines = secondLanguageDialogues.map { $0.line() }
    
    // TODO: 可以构造一个配置文件，比如 subtitle_config
    // 里面指定需要留下的 style，以及 style 的顺序，然后这里读取
    // 以金田一少年事件簿 R 为例
    // CN
    // OP
    // CN
    // OP?
    // ED
    // CN
    let mainDialogues = mainDialogueLines.map( { Dialogue(eventLine: $0) })
        .filter( { $0.text.count > 0} )
        .sorted { $0.start < $1.start }
    
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
    
    var organizedDialogues = [Comment(content: "Prologue")] + prologue
        + [Comment(content: "OP")] + OP
        + [Comment(content: "正片")] + content
        + [Comment(content: "ED")] + ED
    
    if nextEpisodePreview.count > 0 {
        organizedDialogues += [Comment(content: "下集预告")] + nextEpisodePreview
    }
    organizedDialogues += [Comment(content: "JP")]
    
    organizedDialogues.forEach { dialogue in
        // TODO： 移除前后空格
        dialogue.text = ChineseConverter.shared.convert(dialogue.text)
    }
    let organizedDialogueLines = organizedDialogues.map { $0.line() } + secondLanguageDialogueLines
    
    let organizedLines = nonDialogueLines + organizedDialogueLines
    
    // TODO: 支持替换自定义字符
    // 比如金田一中的 style TITEL -> TITLE
    let result = organizedLines.joined(separator: "\r\n").replacingOccurrences(of: "TITEL", with: "TITLE")
    // 修改前的字幕文件备份起来，扩展名改成 ssa
    // 这样既可以和新生成的 .ass 文件区分开来，方便地批量删除
    // 又可以直接双击在 VS Code 中打开，方便比对
    let backupURL = url.appendingPathExtension("backup.ssa")
    if FileManager.default.fileExists(atPath: backupURL.path) {
        try FileManager.default.removeItem(at: backupURL)
    }
    try FileManager.default.moveItem(at: url, to: backupURL)
    try result.write(to: url, atomically: false, encoding: .utf8)
}

func shiftFile(at url: URL, seconds: Double) throws {
    let subtitle = try String(contentsOf: url)
    var lines = subtitle.replacingOccurrences(of: "\r\n", with: "\n")
        .replacingOccurrences(of: "\n", with: "\r\n")
        .components(separatedBy: "\r\n")
    
    var dialogues = [Dialogue]()
    lines.enumerated().forEach { line in
        if line.element.hasPrefix("Dialogue:") {
            let dialogue = Dialogue.init(eventLine: line.element, lineNumber: line.offset)
            dialogues.append(dialogue)
        }
    }
    
    dialogues.forEach { dialogue in
        dialogue.start = shift(time: dialogue.start, seconds: seconds)
        dialogue.end = shift(time: dialogue.end, seconds: seconds)
        
        lines[dialogue.lineNumber] = dialogue.line()
    }
    
    let result = lines.joined(separator: "\r\n")
    // 修改前的字幕文件备份起来
    let backupURL = url.appendingPathExtension("backup.ass")
    if FileManager.default.fileExists(atPath: backupURL.path) {
        try FileManager.default.removeItem(at: backupURL)
    }
    try FileManager.default.moveItem(at: url, to: backupURL)
    try result.write(to: url, atomically: false, encoding: .utf8)
}

private func shift(time: String, seconds: Double) -> String {
    let formatter = DateFormatter()
    // 大写的 H 表示 24 小时制，否则会出现
    // before: 0:02:35.01
    // after: 12:02:33.51
    // 用 H 而不是 HH，否则会出现
    // before: 0:02:35.01
    // after: 00:02:33.51
    formatter.dateFormat = "H:mm:ss.SS"
    
    let newTime = formatter.date(from: time)!.addingTimeInterval(seconds)
    let result = formatter.string(from: newTime)
    
    return result
}
