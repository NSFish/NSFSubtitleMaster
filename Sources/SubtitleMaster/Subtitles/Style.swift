//
//  Style.swift
//  SubtitleMaster
//
//  Created by nsfish on 2021/9/25.
//

import Foundation

final class Style: PartOfSubtitles {
    
    class var header: String {
        return "Style: "
    }
    
    var name: String = ""
    let fontName: String
    let fontSize: String

    /// 主要填充颜色
    let primaryColour: String

    /// 次要填充颜色，用于标准卡拉OK模式下的预填充
    let secondaryColour: String

    /// 字体边框颜色
    let outlineColour: String

    /// 字体阴影色
    let backColour: String

    /// 粗体，1开启，0关闭
    let bold: String

    /// 斜体，1开启，0关闭
    let italic: String

    /// 下划线，1开启，0关闭
    let underline: String

    /// 删除线，1开启，0关闭
    let strikeOut: String

    /// 宽度缩放，单位为%，默认100
    let scaleX: String

    /// 高度缩放，单位为%，默认100
    let scaleY: String

    /// 字体间距
    let spacing: String

    /// 旋转角度
    let angle: String

    /// 边框样式；默认为1，即使用正常字体边框，设置为3时，则使用不透明背景取代字体边框
    let borderStyle: String

    /// 边框宽度
    let outline: String

    /// 阴影距离
    let shadow: String

    /// 字幕对齐方式(同小键盘上数字的位置)
    let alignment: String

    /// 左边距
    let marginL: String

    /// 右边距
    let marginR: String

    /// 垂直边距
    let marginV: String

    /// 字体编码；默认为1
    let encoding: String
    
    init(line: String) {
        let content = line.replacingOccurrences(of: Style.header, with: "")
        
        let values = content.components(separatedBy: ",")
                
        name = values[0]
        fontName = values[1]
        fontSize = values[2]
        primaryColour = values[3]
        secondaryColour = values[4]
        outlineColour = values[5]
        backColour = values[6]
        bold = values[7]
        italic = values[8]
        underline = values[9]
        strikeOut = values[10]
        scaleX = values[11]
        scaleY = values[12]
        spacing = values[13]
        angle = values[14]
        borderStyle = values[15]
        outline = values[16]
        shadow = values[17]
        alignment = values[18]
        marginL = values[19]
        marginR = values[20]
        marginV = values[21]
        encoding = values[22]
    }
}

extension Style: CustomStringConvertible {
    
    var description: String {
        
        return Self.header + name
    }
}

extension Style {
    
    func line() -> String {
        return Self.header
        + name + ","
        + fontName + ","
        + fontSize + ","
        + primaryColour + ","
        + secondaryColour + ","
        + outlineColour + ","
        + backColour + ","
        + bold + ","
        + italic + ","
        + underline + ","
        + strikeOut + ","
        + scaleX + ","
        + scaleY + ","
        + spacing + ","
        + angle + ","
        + borderStyle + ","
        + outline + ","
        + shadow + ","
        + alignment + ","
        + marginL + ","
        + marginR + ","
        + marginV + ","
        + encoding
    }
}
