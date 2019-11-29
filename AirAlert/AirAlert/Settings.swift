//
//  Settings.swift
//  AirAlert
//
//  Created by hyf on 17/10/24.
//  Copyright © 2017年 hyf. All rights reserved.
//

import Foundation

class Settings {
    
    static let sharedInstance = Settings()
    
    private struct Constants {
        static let alertLevel = "AlertLevel"
        static let recoveryEnabled = "RecoveryEnabled"
        //static let cityName = "CityName"
        static let stationID = "StationID"
        static let deviceToken = "DeviceToken"
        static let languageID = "LanguageID" // 0: english 1: chinese
        
        struct Defaults {
            static let alertLevel = NSNumber(value: 2 as Int32) // default, alert if AQI  >= 101
            static let recoveryEnabled = true
            static let stationID = -1
            static let deviceToken = ""
            static let languageID = -1 // language unselected
        }
    }
    
   
    var alertLevel: NSInteger {
        get {
            if let alertLevel = UserDefaults.standard.value(forKey: Constants.alertLevel) as? NSNumber {
                return alertLevel.intValue
            } else {
                return Constants.Defaults.alertLevel.intValue
            }
        }
        set {
            UserDefaults.standard.setValue(NSNumber(value: newValue as Int), forKey: Constants.alertLevel)
            // didSet
            AirRequest.sharedInstance.updateSettings { (data, error) in print("update settings: alertLevel") }
        }
    }
    
    var recoveryEnabled: Bool {
        get {
            if let recoveryEnabled = UserDefaults.standard.value(forKey: Constants.recoveryEnabled) as? Bool {
                return recoveryEnabled
            } else {
                return Constants.Defaults.recoveryEnabled
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.recoveryEnabled)
            // didSet
            AirRequest.sharedInstance.updateSettings { (data, error) in print("update settings: recoveryEnabled") }
        }
    }
    
    var stationID: Int {
        get {
            return UserDefaults.standard.value(forKey: Constants.stationID) as? Int ?? Constants.Defaults.stationID
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.stationID)
            // didSet
            // merge updatesetting() with getairdata()
        }
    }
    
    // there is no station ID, while opening app the first time
    func NoStationSelected() -> Bool {
        return stationID == Constants.Defaults.stationID
    }
    
    var deviceToken: String {
        get {
            return UserDefaults.standard.value(forKey: Constants.deviceToken) as? String ?? Constants.Defaults.deviceToken
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.deviceToken)
            // didSet
            // registe service
            for _ in 1...20 {
                if Settings.sharedInstance.NoStationSelected() { sleep(1) }
                else
                { break }
            }
            AirRequest.sharedInstance.updateSettings { (data, error) in print("update settings: device token") }
        }
    }
    
    // there is no device token, while opening app the first time
    func NoDeviceToken() -> Bool {
        return deviceToken == Constants.Defaults.deviceToken
    }
    
    var languageID: Int {
        get {
            return UserDefaults.standard.value(forKey: Constants.languageID) as? Int ?? Constants.Defaults.languageID
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.languageID)
            // didSet
            // merge updatesetting() with getairdata()
        }
    }
    
    // there is no language be set, while opening app the first time
    func NoAppLanguage() -> Bool {
        return languageID == Constants.Defaults.languageID
    }
    
    enum myLanguage : String {
        case english = "Base"
        case chinese = "zh-Hans"
    }
    
    func setAppLanguage() {
        let language = (languageID==1) ? myLanguage.chinese : myLanguage.english
        //print(language.rawValue)
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        
        // update setting
        // refresh city.name by language
        
        
        return Bundle.setLanguage(language.rawValue)
    }
    
    func initAppLanguage(languageDef: String) {
        if languageDef == myLanguage.chinese.rawValue {
            languageID = 1 // use default language as app language
        } else {
            languageID = 0
            setAppLanguage()
        }
    }
}
