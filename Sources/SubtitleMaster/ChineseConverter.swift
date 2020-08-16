//
//  ChineseConverter.swift
//  SubtitleMaster
//
//  Created by nsfish on 2020/8/16.
//

import Foundation
import OpenCC

final class ChineseConverter {
    
    static let shared = ChineseConverter()
    
    let internalConverter: OpenCC.ChineseConverter
    
    private init(){
        let bundleURL = URL.init(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/Github/SwiftyOpenCC/OpenCCDictionary.bundle")
        let bundle = Bundle.init(url: bundleURL)!
        self.internalConverter = try! OpenCC.ChineseConverter(bundle: bundle, option: [.simplify])
    }
    
    func convert(_ string: String) -> String {
        var result = internalConverter.convert(string)
        result = result.replacingOccurrences(of: "於", with: "于")
            .replacingOccurrences(of: "网路", with: "网络")
            .replacingOccurrences(of: "怎幺", with: "怎么")
            .replacingOccurrences(of: "什幺", with: "什么")
            .replacingOccurrences(of: "这幺", with: "这么")
            .replacingOccurrences(of: "骇客", with: "黑客")
            .replacingOccurrences(of: "於", with: "于")
        
        return result
    }
}
