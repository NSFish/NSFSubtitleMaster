//
//  String+Extension.swift
//  SubtitleMaster
//
//  Created by nsfish on 2021/9/25.
//

import Foundation

extension String {
    
    static var endOfLine: String {
        return "\r\n"
    }
    
    func forceEndOfLineToBeRN() -> String {
        return self.replacingOccurrences(of: Self.endOfLine, with: "\n")
            .replacingOccurrences(of: "\n", with: Self.endOfLine)
    }
}
