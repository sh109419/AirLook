//
//  Data.swift
//  AirAlert
//
//  Created by hyf on 2018/8/17.
//  Copyright © 2018年 Deng Junqiang. All rights reserved.
//

import Foundation
import UIKit

// 全局变量
var nearestOfAirData: NearestList = []

var airData = AirData() {
    didSet {
        nearestOfAirData.removeAll()// reload nearestlist if airdata updated
    }
}


// response are JSON Data
/*struct ResponseData: Codable {
    let status: String // status code
    let data: AirData //real-time air quality infomrmation.
}*/

struct AirData: Codable {
    let idx: Int? // monitoring station index
    let aqi: Int?
    let city: City? // monitoring station
    let dominentpol: String? // dominant pollution
    let iaqi: Iaqi? // Individual AQI
    let time: DateTime? //Local measurement time
    let forecast_aqi: Forecast?
    
    struct City: Codable {
        //let geo: [Float]?
        let name: String?
        let name2: String?
        
        func localizedName() -> String {
            
            if (Settings.sharedInstance.languageID == 1) {
                if let name2 = self.name2 {
                    return name2
                }
            }
            return self.name ?? ""
        }
    }
    
    struct Forecast: Codable {
        let hour24: [[Int]]?
        let daily: [[Int]]?
        let now: Int? // the time match with the 1st record
        
        func active() -> Bool {
            return (self.now ?? 0) > 0
        }
        
        func getHourString(index: Int) -> String {
            let timeStamp = self.now
            if timeStamp == nil { return "" }
            
            let timeInterval: TimeInterval = TimeInterval(timeStamp! + index*3*60*60)
            let date = Date(timeIntervalSince1970: timeInterval)
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
            
            formatter.dateFormat = "H:mm"// 短格式 对齐
            let parsedDate = formatter.string(from: date) as String
            return parsedDate
            
        }
        func getDayofWeek(dayIndex: Int) -> String {
            let timeStamp = self.now
            if timeStamp == nil { return "" }
            
            let timeInterval: TimeInterval = TimeInterval(timeStamp!+dayIndex*24*60*60)
            let date = Date(timeIntervalSince1970: timeInterval)
            let formatter = DateFormatter()
            formatter.locale = myLocale()
            formatter.dateFormat = "EEEE"// 短格式 对齐
            formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
            let parsedDate = formatter.string(from: date) as String
            return parsedDate
        }
        
        func getAqiRangeString(dayIndex: Int) -> String {
            var ret = ""
            if let daily = self.daily {
                if daily[dayIndex].count == 2 {// avoid index out of range
                    let min = daily[dayIndex][0]
                    let max = daily[dayIndex][1]
                    ret = "\(max)" + fixedLengthIntString(value: min)
                }
            }
            return ret
        }
        
        func getMaxDailyAqi(dayIndex: Int) -> Int {
            var ret = -1
            if let daily = self.daily {
                if daily[dayIndex].count == 2 {
                    ret = daily[dayIndex][1]
                }
            }
            return ret
        }
    }
    
    // MARK: individual AQI
    struct Iaqi: Codable {
        let humidity: Float?
        let no2: Float?
        let presure: Float?
        let pm10: Float?
        let pm25: Float? //PM2.5
        let temp: Float?
        let wind: Float?
        let co: Float?
        let o3: Float?
        let so2: Float?
        
        private enum CodingKeys : String, CodingKey {
            case humidity = "h"
            case presure = "p"
            case temp = "t"
            case wind = "w"
            case no2,pm10,pm25,co,o3,so2
        }

        func getIAqiDetails() -> [IAqiDetail] {
            var keys = [IAqiDetail]()
            var detail = IAqiDetail()
            if self.pm25 != nil {
                detail.key = "pm25"
                detail.aqi = Int(self.pm25!)
                keys.append(detail)
            }
            if self.pm10 != nil {
                detail.key = "pm10"
                detail.aqi = Int(self.pm10!)
                keys.append(detail)
            }
            if self.o3 != nil {
                detail.key = "o3"
                detail.aqi = Int(self.o3!)
                keys.append(detail)
            }
            if self.no2 != nil {
                detail.key = "no2"
                detail.aqi = Int(self.no2!)
                keys.append(detail)
            }
            if self.so2 != nil {
                detail.key = "so2"
                detail.aqi = Int(self.so2!)
                keys.append(detail)
            }
            if self.co != nil {
                detail.key = "co"
                detail.aqi = Int(self.co!)
                keys.append(detail)
            }
            return keys
        }

        
        func getWeatherInfo() -> String {
            var weather = ""
            if let temp = self.temp {
                let s = String(format: "%.0f", temp)
                weather = s + "℃"
            }
            if let humidity = self.humidity {
                let s = String(format: "%.0f", humidity)
                weather = weather + "  " + s + "%"
            }
            return weather
        }
    }
    
    struct DateTime: Codable {
        let timeStr: String? //dateFormat: 格式化样式，默认为“yyyy-MM-dd HH:mm:ss”
        
        private enum CodingKeys: String, CodingKey {
            case timeStr = "s"
        }
        
        func getTimeString() -> String {
            if let str = self.timeStr {
                let startIndex = str.index(str.endIndex, offsetBy:-8)
                let endIndex = str.index(str.endIndex, offsetBy:-3)
                let result = str[startIndex ..< endIndex]
                return String(result)
            }
            return ""
        }
        
        func getUpdatedTimeString() -> String {
            let timeFormatter = airDateFormatter()
            guard
                let str = self.timeStr,
                let date = timeFormatter.date(from: str)
            else {
                return ""
            }
            
            let formatter = DateFormatter()
            formatter.locale = myLocale()
            formatter.dateFormat = "EEE H:mm"
            //formatter.local
            //formatter.dateStyle = .medium
            //let updated = "Updated on " + formatter.string(from: date) as String
            let updated = String(format: "Updated on %@".localized,
                                 formatter.string(from: date) as String)
            return updated
        }
    }
    
    // MARK: - Internal Implementation
    
    init?() {
        // restore defaults
        guard
            //let savedData = UserDefaults.standard.data(forKey: Constants.airDataStoredKey),
            let groupShared = UserDefaults.init(suiteName: Constants.groupID),
            let savedData = groupShared.data(forKey: Constants.airDataStoredKey),
            let data = try? JSONDecoder().decode(AirData.self, from: savedData)
        else {
            return nil
        }
        self = data
    }
    
}

extension AirData {
    // save data
    func Save() {
        if let data = try? JSONEncoder().encode(self) {
           // UserDefaults.standard.set(data, forKey: Constants.airDataStoredKey)
            let groupShared = UserDefaults.init(suiteName: Constants.groupID)
            groupShared?.set(data, forKey: Constants.airDataStoredKey)
            groupShared?.synchronize()
            
        }
    }
    
    // MARK: - time functions
    
    // if city changed, refresh now
    // 数据每小时刷新一次
    func OutOfDate() -> Bool {
        if self.idx != Settings.sharedInstance.stationID { return true }
        
        guard let dateStr = self.time?.timeStr else { return true }
        
        let interval = dateStringTimeIntervalSinceNow(dateString: dateStr)
        print(interval)
        return (interval / (60*60) > 1)
    }
    
    func OutOfDate4Widget() -> Bool {
        // remove 'Settings', Settings are not shared with widget
        //if self.idx != Settings.sharedInstance.stationID { return true }
        
        guard let dateStr = self.time?.timeStr else { return true }
        
        let interval = dateStringTimeIntervalSinceNow(dateString: dateStr)
        print(interval)
        return (interval / (60*60) > 1)
    }
    
}

// MARK: - airdata -- nearest

typealias NearestList = [Nearest]

struct Nearest: Decodable {
    let airdata_idx: Int?// monitoring station index
    let idx: Int? // nearest station index
    let aqi: Int?
    let name: String? // nearest station
    let name2: String?
    let latitude: Float?
    let longitude: Float?
    let vtime: Int? //Local measurement time
}

// MARK: -  iaqi display information
struct IAqiDetail {
    var key: String?
    var aqi: Int?
    //var isDominentpol: Bool?
}

// MARK: -  functions
func fixedLengthIntString(value: Int) -> String {
    //原始值
    let number = NSNumber(value: value)
    //创建一个NumberFormatter对象
    let numberFormatter = NumberFormatter()
    //设置number显示样式
    numberFormatter.paddingCharacter = " " //不足位数用" "补
    numberFormatter.formatWidth = 4 //补齐10位
    numberFormatter.paddingPosition = .beforePrefix//补在前面
    //格式化
    let format = numberFormatter.string(from: number)!
    return format
}

func airDateFormatter() -> DateFormatter  {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"//use fixed format
    return formatter
}

//通过timeStamp比较给定时间与当前时间的差值
fileprivate func dateStringTimeIntervalSinceNow(dateString: String) -> Double {
    let timeFormatter = airDateFormatter()
    let date = timeFormatter.date(from: dateString)
    let diff = date?.timeIntervalSinceNow ?? 0
    return (-1 * diff)
}

// constants

 private struct Constants {
    // for group shared storage
    static let airDataStoredKey = "AirDataStored"
    static let groupID = "group.com.hyf.AirAlert"
}


// MARK: - Search Data

typealias SearchDataArray = [SearchData]

struct SearchData: Decodable {
    let idx: Int? // monitoring station index
    let aqi: Int?
    let station: String? // monitoring station
    let stime: String? //Local measurement time
}

