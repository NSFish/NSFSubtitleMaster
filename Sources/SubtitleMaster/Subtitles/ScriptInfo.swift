//
//  ScriptInfo.swift
//  SubtitleMaster
//
//  Created by nsfish on 2021/9/25.
//

import Foundation

// http://www.tcax.org/docs/ass-specs.htm
final class ScriptInfo: PartOfSubtitles {
    
    let openingMark = "[Script Info]"
    
    enum ScriptType: String {
        case ssa = "v4.00"
        case ass = "v4.00+"
    }
    
    let scriptType: ScriptType = .ass
    
    let originalScript: String
    let playResX: String
    let playResY: String
    let YCbCrMatrix: String
    
    init(lines:[String]) {
        var content = [String:String]()
        lines.forEach { line in
            let pair = line.components(separatedBy: Self.seperator)
            content[pair.first!] = pair.last!
        }
        
        originalScript = content[Self.originalScriptKey] ?? ""
        playResX = content[Self.playResXKey] ?? ""
        playResY = content[Self.playResYKey] ?? ""
        YCbCrMatrix = content[Self.YCbCrMatrixKey] ?? ""
    }
    
    func lines() -> [String] {
        return [Self.originalScriptKey + Self.seperator + originalScript,
                Self.scriptTypeKey + Self.seperator + self.scriptType.rawValue,
                Self.playResXKey + Self.seperator + playResX,
                Self.playResYKey + Self.seperator + playResY,
                Self.YCbCrMatrixKey + Self.seperator + YCbCrMatrix]
    }
}

extension ScriptInfo {
    
    class var seperator: String {
        return ": "
    }
    
    class var originalScriptKey: String {
        return "Original Script"
    }
    
    class var scriptTypeKey: String {
        return "ScriptType"
    }
    
    class var playResXKey: String {
        return "PlayResX"
    }
    
    class var playResYKey: String {
        return "PlayResY"
    }
    
    class var YCbCrMatrixKey: String {
        return "YCbCr Matrix"
    }
}
