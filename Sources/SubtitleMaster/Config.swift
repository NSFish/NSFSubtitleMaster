//
//  Config.swift
//  SubtitleMaster
//
//  Created by nsfish on 2021/9/25.
//

import Foundation

final class Config {
    
    var styleNamesMapping = [String:String]()
    var styles = [Style]()
    
    init(url: URL) throws {
        let content = try String(contentsOf: url)
        
        let lines = content.forceEndOfLineToBeRN().components(separatedBy: String.endOfLine)
        
        // Style Name Mapping
        let styleNameMappingOpeningMark = "[Style Name Mapping]"
        guard let styleNameMappingOpeningMarkIndex = lines.firstIndex(where: { $0 == styleNameMappingOpeningMark }) else {
            throw SubtitleMasterError.noStyles
        }
        
        let styleNameMappingEndIndex = lines[styleNameMappingOpeningMarkIndex...].firstIndex(of: "") ?? lines.endIndex
        let styleNameMappingLines = Array(lines[(styleNameMappingOpeningMarkIndex + 1)..<styleNameMappingEndIndex])
        styleNameMappingLines.forEach { line in
            let mapping = line.components(separatedBy: " -> ")
            styleNamesMapping[mapping.first!] = mapping.last!
        }
                
        // Style
        let styleOpeningMark = "[Style]"
        guard let styleOpeningMarkIndex = lines.firstIndex(where: { $0 == styleOpeningMark }) else {
            return
        }
        
        let styleEndIndex = lines[styleOpeningMarkIndex...].firstIndex(of: "") ?? lines.endIndex
        let styleLines = Array(lines[(styleOpeningMarkIndex + 1)..<styleEndIndex])

        styles = styleLines.map { Style.init(line: $0) }        
    }
}
