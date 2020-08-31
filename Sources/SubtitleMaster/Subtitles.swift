//
//  Subtitles.swift
//  SubtitleMaster
//
//  Created by nsfish on 2020/9/1.
//

import Foundation

protocol PartOfSubtitles {}

// http://www.tcax.org/docs/ass-specs.htm
final class ScriptInfo: PartOfSubtitles {
    
    enum ScriptType: String {
        case ssa = "v4.00"
        case ass = "v4.00+"
    }
    
    let title: String = ""
    let originalScript: String = ""
    let scriptType: ScriptType = .ass
    let playResX: String = ""
    let playResY: String = ""
    let timer: String = ""
}

final class Style: PartOfSubtitles {
    
    var name: String = ""
    let fontName: String = ""
    let fontSize: String = ""

    /// 主要填充颜色
    let primaryColour: String = ""

    /// 次要填充颜色，用于标准卡拉OK模式下的预填充
    let secondaryColour: String = ""

    /// 字体边框颜色
    let outlineColour: String = ""

    /// 字体阴影色
    let backColour: String = ""

    /// 粗体，1开启，0关闭
    let bold: String = "0"

    /// 斜体，1开启，0关闭
    let italic: String = ""

    /// 下划线，1开启，0关闭
    let underline: String = "0"

    /// 删除线，1开启，0关闭
    let strikeOut: String = "0"

    /// 宽度缩放，单位为%，默认100
    let scaleX: String = "100"

    /// 高度缩放，单位为%，默认100
    let scaleY: String = "100"

    /// 字体间距
    let spacing: String = ""

    /// 旋转角度
    let angle: String = ""

    /// 边框样式；默认为1，即使用正常字体边框，设置为3时，则使用不透明背景取代字体边框
    let borderStyle: String = "1"

    /// 边框宽度
    let outline: String = ""

    /// 阴影距离
    let shadow: String = ""

    /// 字幕对齐方式(同小键盘上数字的位置)
    let alignment: String = "2"

    /// 左边距
    let marginL: String = ""

    /// 右边距
    let marginR: String = ""

    /// 垂直边距
    let marginV: String = ""

    /// 字体编码；默认为1
    let encoding: String = "1"
}

final class Subtitles {
    
    let url: URL
    
//    var scriptInfo
    
    init(url: URL) {
        self.url = url
    }
    
}
