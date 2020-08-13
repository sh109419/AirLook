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
        static let stationSelected = "StationSelected"
        static let tokenToDB = "TokenToDB"
        
        struct Defaults {
            static let alertLevel = NSNumber(value: 2 as Int32) // default, alert if AQI  >= 101
            static let recoveryEnabled = true
            static let stationID = 3304 // default show shanghai
            static let deviceToken = ""
            static let languageID = -1 // language unselected
            static let stationSelected = false
            static let tokenToDB = false
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
            AirRequest.sharedInstance.changeAlertLevel { (data, error) in print("update settings: alertLevel") }
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
            AirRequest.sharedInstance.changeRecoveryEnabled { (data, error) in print("update settings: recoveryEnabled") }
        }
    }
    
    var stationID: Int {
        get {
            return UserDefaults.standard.value(forKey: Constants.stationID) as? Int ?? Constants.Defaults.stationID
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.stationID)
            // didSet
             AirRequest.sharedInstance.changeStationID { (data, error) in print("update settings: station id-\(Settings.sharedInstance.stationID)") }
        }
    }
    
    // there is no station ID, while opening app the first time
    
    var stationSelected: Bool {
        get {
            return UserDefaults.standard.value(forKey: Constants.stationSelected) as? Bool ?? Constants.Defaults.stationSelected
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.stationSelected)
        }
    }
    
    
    var deviceToken: String {
        get {
            return UserDefaults.standard.value(forKey: Constants.deviceToken) as? String ?? Constants.Defaults.deviceToken
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.deviceToken)
            // didSet
            AirRequest.sharedInstance.newToken { (data, error) in
                DispatchQueue.main.async {
                    // handle errors
                    guard let data = data, error == nil else {
                        print(error ?? "newToken.error")
                        return
                    }
                    //print(data as String)
                    // parsing JSON data
                    guard
                        let json = try? JSONSerialization.jsonObject(with: data),
                        let dictionary = json as? [String: Any],
                        let result = dictionary["result"] as? Bool
                        else {
                            print("JSON parsing failed: @newToken")
                            return
                    }
                    print("device token is in DB")
                    Settings.sharedInstance.tokenToDB = result
                }
            }
            
        }
    }
    
    // there is no device token, while opening app the first time
    
    func NoDeviceToken() -> Bool {
        return deviceToken == Constants.Defaults.deviceToken
    }
    
    // make sure the device token sent to db
    var tokenToDB: Bool {
        get {
            return UserDefaults.standard.value(forKey: Constants.tokenToDB) as? Bool ?? Constants.Defaults.tokenToDB
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.tokenToDB)
        }
    }
    
    
    // local stored
    var languageID: Int {
        get {
            return UserDefaults.standard.value(forKey: Constants.languageID) as? Int ?? Constants.Defaults.languageID
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.languageID)
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
