//
//  Event.swift
//  SubtitleMaster
//
//  Created by nsfish on 2020/8/16.
//  Copyright © 2020 nsfish. All rights reserved.
//

import Foundation

class Event {
    
    class var header: String {
        return ""
    }
        
    let layer: String
    let start: String
    let end: String
    let style: String
    let name: String
    let marginL: String
    let marginR: String
    let marginV: String
    let effect: String
    var text: String

    init(eventLine: String){
        let properties = eventLine.components(separatedBy: ",")
        layer = properties[0]
        start = properties[1]
        end = properties[2]
        style = properties[3]
        name = properties[4]
        marginL = properties[5]
        marginR = properties[6]
        marginV = properties[7]
        effect = properties[8]
        
        // text 中也可能包含 ",", 需要特殊处理
        var text = ""
        for i in 9..<properties.endIndex {
            text += properties[i]
            
            if i < properties.endIndex - 1 {
                text += ","
            }
        }
        self.text = text
    }
    
    func line() -> String {
        var array = [String]()
        let mirrored = Mirror(reflecting: self)
        
        guard let superClassMirrored = mirrored.superclassMirror else {
            return ""
        }
        
        for property in superClassMirrored.children {
            array.append(property.value as! String)
        }
        
        return Self.header + array.joined(separator: ",")
    }
}


final class Dialogue: Event {
    
    override class var header: String {
        return "Dialogue: "
    }

    override init(eventLine: String) {
        let content = eventLine.replacingOccurrences(of: Dialogue.header, with: "")
        super.init(eventLine: content)
    }
}

extension Dialogue: CustomStringConvertible {
    
    var description: String {
        return Self.header + " - layer: " + layer + ", style: " + style + ", text: " + text
    }
}


final class Comment: Event {
    
    override class var header: String {
        return "Comment: "
    }
    
    class var commentSeparator: String {
        return "--------------"
    }
    
    @available(*, unavailable)
    override init(eventLine: String) {
        fatalError()
    }
    
    init(content: String) {
        super.init(eventLine: "0,0:00:00.00,0:00:00.00,Default,,0,0,0,,"
        + Comment.commentSeparator
        + content
        + Comment.commentSeparator)
    }
}
