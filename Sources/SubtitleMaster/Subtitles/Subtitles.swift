//
//  Subtitles.swift
//  SubtitleMaster
//
//  Created by nsfish on 2020/9/1.
//

import Foundation
import AppKit

protocol PartOfSubtitles {}

// 生命周期: Init -> Parse -> WriteBack
final class Subtitles {
    
    let url: URL
    
    let scriptInfoOpeningMark = "[Script Info]"
    var scriptInfo: ScriptInfo!
    
    let styleOpeningMark = "[V4+ Styles]"
    let styleFormat: String
    var styles: [Style]!
    
    let dialogueOpeningMark: String = "[Events]"
    let dialogueFormat: String
    var dialogues: [Dialogue]!
        
    init(url: URL) {
        styleFormat = "Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding"
        dialogueFormat = "Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text"
        
        self.url = url
    }
    
    func parse() throws {
        let subtitle = try String(contentsOf: url)
        // 文件中的换行符有的是 \r\n，有的只有 \n，提前做个统一处理
        let lines = subtitle.forceEndOfLineToBeRN()
            .components(separatedBy: String.endOfLine)
        
        guard let styleOpeningMarkIndex = lines.firstIndex(where: { $0 == styleOpeningMark }) else {
            throw SubtitleMasterError.noStyles
        }
        let scriptInfoLines = Array(lines[0..<styleOpeningMarkIndex])
        scriptInfo = ScriptInfo.init(lines: scriptInfoLines)
        
        let styleLines = lines.filter { line in
            return line.hasPrefix(Style.header)
        }
        styles = styleLines.map( { Style.init(line: $0) })

        let dialogueLines = lines.filter { $0.hasPrefix(Dialogue.header) }
        dialogues = dialogueLines.map({ Dialogue.init(eventLine: $0) })
        dialogues.forEach { $0.text = $0.text.replacingOccurrences(of: "  ", with: " ") }
    }
    
    func modifyWith(config: Config) {
        // Style Name Mapping
        styles = styles.filter{ config.styleNamesMapping.keys.contains($0.name) }
        styles.forEach { $0.name = config.styleNamesMapping[$0.name]! }
        
        dialogues = dialogues.filter{ $0.text.count > 0 && config.styleNamesMapping.keys.contains($0.style)}
        dialogues.forEach { $0.style = config.styleNamesMapping[$0.style]! }
        
        // Style
        config.styles.forEach { styleInConfig in
            if let matchedIndex = styles.firstIndex(where: { $0.name == styleInConfig.name }) {
                styles[matchedIndex] = styleInConfig
            }
        }
    }
    
    func writeBack() throws {
        var lines = [String]()
        
        lines.append(scriptInfoOpeningMark)
        lines.append(contentsOf: scriptInfo.lines())
        
        lines.append("")
        lines.append(styleOpeningMark)
        lines.append(styleFormat)
        styles.forEach { lines.append($0.line()) }
        
        lines.append("")
        lines.append(dialogueOpeningMark)
        lines.append(dialogueFormat)
        dialogues.forEach { lines.append($0.line()) }
        
        let result = lines.joined(separator: String.endOfLine)
        // 修改前的字幕文件备份起来，扩展名改成 ssa
        // 这样既可以和新生成的 .ass 文件区分开来，方便批量删除
        // 又可以直接双击在 VS Code 中打开，方便比对
        let backupURL = url.appendingPathExtension("backup.ssa")
        if FileManager.default.fileExists(atPath: backupURL.path) {
            try FileManager.default.removeItem(at: backupURL)
        }
        try FileManager.default.moveItem(at: url, to: backupURL)
        try result.write(to: url, atomically: false, encoding: .utf8)
    }
}
