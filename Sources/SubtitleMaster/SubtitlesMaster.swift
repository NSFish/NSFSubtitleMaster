//
//  SubtitlesMaster.swift
//  SubtitleMaster
//
//  Created by nsfish on 2020/9/1.
//

import Foundation
import Runtime

final class SubtitlesMaster {
    
    class func parseFile(at url: URL) throws {
        let subtitles = try String(contentsOf: url)
        // 文件中的换行符有的是 \r\n，有的只有 \n，提前做个统一处理
        let lines = subtitles.replacingOccurrences(of: "\r\n", with: "\n")
            .components(separatedBy: "\n")
        
        // [Script Info]
        guard let styleStartIndex = lines.firstIndex(where: { $0.hasSuffix("Styles]") }) else {
            throw SubtitleMasterError.noStyles
        }
        let scriptInfoLines = Array(lines[0..<styleStartIndex])
        
        var scriptInfo: PartOfSubtitles = ScriptInfo()
        try fillPropertiesFrom(lines: scriptInfoLines, instance: &scriptInfo)
        
//        printPropertiesOf(object: scriptInfo as! ScriptInfo)
        
        // [V4+ Styles]
        guard let eventStartIndex = lines.firstIndex(where: { $0.hasSuffix("[Events]") }) else {
            throw SubtitleMasterError.noEvents
        }
        
        let styleLines = Array(lines[styleStartIndex..<eventStartIndex])
        let formatLineIndex = styleLines.firstIndex { $0.hasPrefix("Format: ") }!
        let formatLine = styleLines[formatLineIndex]
            .replacingOccurrences(of: "Format: ", with: "")
        let styleNames = formatLine.components(separatedBy: ",")
        
        let styleDetailLines = Array(styleLines[(formatLineIndex + 1)..<styleLines.endIndex])
            .filter({ $0.count > 0 })
            .map { $0.replacingOccurrences(of: "Style: ", with: "") }
        
        var styles = [Style]()
        try styleDetailLines.forEach { line in
            let styleValues = line.components(separatedBy: ",")
            
            var style = Style()
            
            let mirrored = Mirror(reflecting: style)
            let info = try typeInfo(of: mirrored.subjectType)
            
            for (index, name) in styleNames.enumerated() {
                let value = styleValues[index]
                
                let capitalizedName = name.replacingOccurrences(of: "name", with: "Name")
                    .replacingOccurrences(of: "size", with: "Size")
                    .trimmingCharacters(in: .whitespaces)
                let n = String(capitalizedName.first!)
                let realName = n.lowercased() + String(capitalizedName.dropFirst())
                let runtimeProperty = try info.property(named: realName)
                
                // 居然能设置 let 属性？？
                try runtimeProperty.set(value: value, on: &style)
            }
            
            styles.append(style)
        }
        
        styles.forEach { printPropertiesOf(object: $0) }
        
        // [Events]
    }
    
    class func fillPropertiesFrom(lines: [String], instance: inout PartOfSubtitles) throws {
        var dict = [String:String]()
        lines.forEach { line in
            let components = line.components(separatedBy: ":")
            if components.count == 2 {
                let key = components.first!.replacingOccurrences(of: " ", with: "").lowercased()
                let value = components.last!.trimmingCharacters(in: .whitespacesAndNewlines)
                
                dict[key] = value
            }
        }
        
        let mirrored = Mirror(reflecting: instance)
        
        let info = try typeInfo(of: mirrored.subjectType)
        
        for property in mirrored.children {
            if let propertyName = property.label {
                if let value = dict[propertyName.lowercased()] {
                    let runtimeProperty = try info.property(named: propertyName)
                    try runtimeProperty.set(value: value, on: &instance)
                }
            }
        }
    }
}

func printPropertiesOf(object: Any) {
    let mirrored = Mirror(reflecting: object)
    for property in mirrored.children {
        if let propertyName = property.label,
            let value = property.value as? String {
            print(propertyName + ": " + value)
        }
    }
}
