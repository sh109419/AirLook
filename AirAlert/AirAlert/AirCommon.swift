//
//  Common.swift
//  AirAlert
//
//  Created by hyf on 2018/9/11.
//  Copyright © 2018年 Deng Junqiang. All rights reserved.
//

import Foundation
import UIKit

// MARK: - display style

struct Theme {
    // tableview section header & footer text color
    static let sectionTextColor = UIColor.lightGray
    // tableview section header & footer text font
    static let sectionTextFont = UIFont.systemFont(ofSize: 15)
}

func setSectionTextStyle() {
    UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self])
        .textColor = Theme.sectionTextColor
    UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self])
        .font = Theme.sectionTextFont
}

// MARK: - multi-language

struct MultiLanguage {
    static let languageCount = 2
    
    static let record = ["English","简体中文"]
    
    // Air Pollution Level
    static func getLanguageText(id: Int) -> String {
        let index = (id==1) ? id : 0
        return MultiLanguage.record[index]
    }
    
    
}
// MARK: - Air Quality Index Scale and Color Legend

//The table below defines the Air Quality Index scale as defined by the US-EPA 2016 standard

struct AqiTable {
    
    static let recordCount = 6 // 6 levels, each level is a record
    static let rowCount = 3 // aqi, apl, desc
    
    static let record: [AqiRecord] = [
        AqiRecord(aqi: "0-50",
                  apl: "Good",
                  desc: "Air quality is considered satisfactory, and air pollution poses little or no risk."),
        AqiRecord(aqi: "51-100",
                  apl: "Moderate",
                  desc: "Air quality is acceptable; however, for some pollutants there may be a moderate health concern for a very small number of people who are unusually sensitive to air pollution."),
        AqiRecord(aqi: "101-150",
                  apl: "Unhealthy for Sensitive Groups",
                  desc: "Members of sensitive groups may experience health effects. The general public is not likely to be affected."),
        AqiRecord(aqi: "151-200",
                  apl: "Unhealthy",
                  desc: "Everyone may begin to experience health effects; members of sensitive groups may experience more serious health effects."),
        AqiRecord(aqi: "201-300",
                  apl: "Very Unhealthy",
                  desc: "Health warnings of emergency conditions. The entire population is more likely to be affected."),
        AqiRecord(aqi: "300+",
                  apl: "Hazardous",
                  desc: "Health alert: everyone may experience more serious health effects.")
    ]
    
    static let recordAQIMin = [0, 51, 101, 151, 201, 301]
    
    /*
     .localized 不能在这里做，”static“ 在运行期不会改变，也就是说，即使language改了，static的常量值还是不会变的
     所以，在引用‘static’的地方做.localized
     */
    
    struct RowTitle {
        static let aqi = "AQI"
        static let apl = "Air Pollution Level"
        static let desc = "Health Implications"
    }
    
    struct AqiRecord {
        let aqi: String // aqi range
        let apl: String // air pollution level
        let desc: String // Health Implications
    }
    
}

// MARK: - Air Self-defined Attentions

struct AttentionConstants {
    static let userdefinedAttentions = "userdefinedAttentions"
    // default attentions' emoji
    static let defaultAttentions = ["🤗", "😐", "🙁", "😷", "😡", "😱"]
    
}

// functions for aqi table

extension AqiTable {
    
    private static func aqiLevel(aqi: Int)-> Int {
        var level = 5
        switch aqi {
        case 0...50:    level = 0
        case 51...100:  level = 1
        case 101...150: level = 2
        case 151...200: level = 3
        case 201...300: level = 4
        case 301...500: level = 5
        default:        level = 5
        }
        return level
    }
    
    // Air Pollution Level
    static func getAirPollutionLevel(aqi: Int) -> String {
        let index = aqiLevel(aqi: aqi)
        return AqiTable.record[index].apl.localized
    }
    
    // Air Health Implications
    static func getHealthImplications(aqi: Int) -> String {
        let index = aqiLevel(aqi: aqi)
        return AqiTable.record[index].desc.localized
    }
    
    // Air Self-defined Attentions
    
    static func getSelfdefinedAttentions(aqi: Int) -> String {
        let index = aqiLevel(aqi: aqi)
        
        if let attentions = UserDefaults.standard.stringArray(forKey: AttentionConstants.userdefinedAttentions) {
            return attentions[index]
        }
        
        return AttentionConstants.defaultAttentions[index]
    }
    
    // MARK: - Color Legend
    
    // aqi label legend
    static func setAqiLabelAsLegend(aqi: Int, label: UILabel) {
        label.textColor = AqiTable.getAQITextColor(aqi: aqi)
        //label.shadowColor = AqiTable.getAQIShadowColor(aqi: aqi)
        label.backgroundColor = AqiTable.getAQIBackgroundColor(aqi: aqi)
        label.text = aqi.description
    }
    
    // aqi cell legend
    static func setAqiCellAsLegend(level: Int, cell: UITableViewCell) {
        let aqi = AqiTable.recordAQIMin[level]
        cell.textLabel?.textColor = AqiTable.getAQITextColor(aqi: aqi)
        //cell.textLabel?.shadowColor = AqiTable.getAQIShadowColor(aqi: aqi)
        cell.detailTextLabel?.textColor = AqiTable.getAQITextColor(aqi: aqi)
        //cell.detailTextLabel?.shadowColor = AqiTable.getAQIShadowColor(aqi: aqi)
        cell.backgroundColor = AqiTable.getAQIBackgroundColor(aqi: aqi)
    }

    // apl label legend
    static func setAplLabelAsLegend(aqi: Int, label: UILabel) {
        label.textColor = AqiTable.getAQIBackgroundColor(aqi: aqi)
      //  label.shadowColor = AqiTable.getAQITextColor(aqi: aqi)
        label.text = AqiTable.getAirPollutionLevel(aqi: aqi)
    }
    
    // aqi image legend
    static func getAqiImageColor(aqi: Int) -> UIColor {
        return getAQIBackgroundColor(aqi: aqi)
    }
    
    static func getAqiImageAsLegend(aqi: Int) -> UIImage {
        let textColor = AqiTable.getAQITextColor(aqi: aqi)
        let backgroundColor = AqiTable.getAQIBackgroundColor(aqi: aqi)
        let text = aqi.description
        let textFont = UIFont.systemFont(ofSize: 12)
        let sourceImage = UIImage(named: "annotation.png")
        let image = sourceImage?.drawTextInImage(text: text, textColor: textColor, textFont: textFont, tintColor: backgroundColor)
        
        return image!
    }
    
    private static let recordTextColor = [
        UIColor.white,
        UIColor.black,
        UIColor.black,
        UIColor.white,
        UIColor.white,
        UIColor.white
    ]
    
    private static let recordShadowColor = [
        UIColor.black,
        UIColor.white,
        UIColor.white,
        UIColor.black,
        UIColor.black,
        UIColor.black
    ]
    
    private static func getAQITextColor(aqi: Int) -> UIColor {
        let index = aqiLevel(aqi: aqi)
        return AqiTable.recordTextColor[index]
    }
    
    private static func getAQIShadowColor(aqi: Int) -> UIColor {
        let index = aqiLevel(aqi: aqi)
        return AqiTable.recordShadowColor[index]
    }
    
    private static let recordBackgroundColorHex = [
        0x009966,
        0xffde33,
        0xff9933,
        0xcc0033,
        0x660099,
        0x7e0023
    ]
    
    private static func getAQIBackgroundColor(aqi: Int) -> UIColor {
        let index = aqiLevel(aqi: aqi)
        return RGBColorFromHex(rgb: AqiTable.recordBackgroundColorHex[index])
    }
    
    // black=rgb(255,255,255) white=rgb(0,0,0)
    private static func RGBColorFromHex(rgb: Int) -> (UIColor) {
        
        return UIColor(red: ((CGFloat)((rgb & 0xFF0000) >> 16)) / 255.0,
                       green: ((CGFloat)((rgb & 0xFF00) >> 8)) / 255.0,
                       blue: ((CGFloat)(rgb & 0xFF)) / 255.0,
                       alpha: 1.0)
    }
    
}

extension UIImage {
    /// 图片加水印&修改底色
    ///
    /// - Parameters:
    ///   - text: 水印完整文字
    ///   - textColor: 文字颜色
    ///   - textFont: 文字大小
    ///   - tintColor: image color
    /// - Returns: 水印图片
    func drawTextInImage(text: String, textColor: UIColor, textFont: UIFont, tintColor: UIColor) -> UIImage {
        // 开启和原图一样大小的上下文（保证图片不模糊的方法）
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        // 图形重绘
        //self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        // change tint color
        //UIGraphicsBeginImageContext(self.size)
        tintColor.setFill()
        let bounds = CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height)
        UIRectFill(bounds)
        self.draw(in: bounds, blendMode: CGBlendMode.destinationIn, alpha: 1.0)
        
        let suffixAttr: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor:textColor, NSAttributedString.Key.font:textFont]
        let attrS = NSMutableAttributedString(string: text, attributes: suffixAttr)
        
        // 文字属性
        let size =  attrS.size()
        let x = (self.size.width - size.width) / 2
        let y = (self.size.height - size.height) / 3
        
        // 绘制文字
        attrS.draw(in: CGRect(x: x, y: y, width: size.width, height: size.height))
        
        // 从当前上下文获取图片
        let image = UIGraphicsGetImageFromCurrentImageContext()
        //关闭上下文
        UIGraphicsEndImageContext()
        
        return image!
    }
}

