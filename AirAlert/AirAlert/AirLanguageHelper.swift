//
//  LanguageHelper.swift
//  AirAlert
//
//  Created by hyf on 2018/12/21.
//  Copyright © 2018年 Deng Junqiang. All rights reserved.
//

import Foundation

/*
  work for Storyboard/XIBs
 */

var bundleKey: UInt8 = 0

class AirBundle: Bundle {
    
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard
            let path = objc_getAssociatedObject(self, &bundleKey) as? String,
            let bundle = Bundle(path: path)
        else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {
    
    class func setLanguage(_ language: String) {
        
        defer {
            // replace bundle.main with Any Language Bundle-airbundle
            object_setClass(Bundle.main, AirBundle.self)
        }
        
        objc_setAssociatedObject(Bundle.main, &bundleKey, Bundle.main.path(forResource: language, ofType: "lproj"), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

/*
 work for Strings
 */
extension String {
    var localized: String {
        return Bundle.main.localizedString(forKey: self, value: nil, table: nil)
    }
}

/*
 work for DateTime
 */

func myLocale() -> Locale {
    if Settings.sharedInstance.languageID == 1 {
        return Locale(identifier: "zh_CN")
    }
    return Locale(identifier: "en")
}
