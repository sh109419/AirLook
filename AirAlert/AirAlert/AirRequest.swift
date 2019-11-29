//
//  Request.swift
//  AirAlert
//
//  Created by hyf on 2018/8/17.
//  Copyright © 2018年 Deng Junqiang. All rights reserved.
//

import Foundation



/* settings upload to server
 
 station id changed:
    func getAirData()
    func getAirDataWithGeo
 
 device token gen:
 alert level changed:
 recovery enabled changed:
    func updateSettings()
 
 */

class AirRequest: NSObject {
    
    static let sharedInstance = AirRequest()
    
    // Completion block for fetch Json Response.
    // { status: ok, data: {} }
    public typealias RequestHandler = (Data?, Error?) -> Swift.Void
    
    
    //MARK: - request data from network
    
    // update settings
    func updateSettings(completed: @escaping RequestHandler) {
        if let url = URL(string: "\(Constants.server)/api_updatesettings.php?id=\(Settings.sharedInstance.stationID)&key=\(Settings.sharedInstance.deviceToken)&level=\(Settings.sharedInstance.alertLevel)&recovery=\(Settings.sharedInstance.recoveryEnabled)") {
            print(url)
            performRequest(url: url) { (data,error) in completed(data, error) }
        }
    }
    
    // request with settings
    func getAirData(completed: @escaping RequestHandler) {
        if let url = URL(string: "\(Constants.server)/api_cityfeed.php?id=\(Settings.sharedInstance.stationID)&key=\(Settings.sharedInstance.deviceToken)&level=\(Settings.sharedInstance.alertLevel)&recovery=\(Settings.sharedInstance.recoveryEnabled)") {
            print(url)
            performRequest(url: url) { (data,error) in completed(data, error) }
        }
    }
    
    // request by widget
    func getAirData4Widget(stationID: Int, completed: @escaping RequestHandler) {
        if let url = URL(string: "\(Constants.server)/api_cityfeed.php?id=\(stationID)") {
            print(url)
            performRequest(url: url) { (data,error) in completed(data, error) }
        }
    }
 
    // request with settings, get station id from location
    func getAirDataWithGeo(latitude: Double, longitude: Double, completed: @escaping RequestHandler) {
      if let url = URL(string: "\(Constants.server)/api_locationfeed.php?geo=\(latitude);\(longitude)&key=\(Settings.sharedInstance.deviceToken)&level=\(Settings.sharedInstance.alertLevel)&recovery=\(Settings.sharedInstance.recoveryEnabled)") {
        print(url)
        performRequest(url: url) { data, error in completed(data, error) }
        }
    }
    
    // Search Request without settings
    func getSearchData(keyword: String, completed: @escaping RequestHandler) {
        // search request
        //https://api.waqi.info/search/?token=c01075aa024f264013e856b80a34fc1d526b404f&keyword=shanghai
        let urlStr = "\(Constants.server)/api_searchbyname.php?keyword=\(keyword)"
        // allow search by Chinese
        let encodedUrl = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        if let url = URL(string: encodedUrl ?? "") {
            print(url)
            performRequest(url: url) { data, error in completed(data, error) }
        }
    }
    
    // get geo base on IP
    func getGeoBaseonIP(completed: @escaping RequestHandler) {
        if let url = URL(string: Constants.getstationbyipurl) {
            print(url)
            performRequest(url: url) { (data,error) in completed(data, error) }
        }
    }
    
    // Nearest Request without Settings Data
    func getNearestList(airdataID: Int, completed: @escaping RequestHandler) {
        // nearest request
        if let url = URL(string: "\(Constants.server)/api_nearestfeed.php?id=\(airdataID)") {
            print(url)
            performRequest(url: url) { data, error in completed(data, error) }
        }
    }
    
    private func performRequest(url: URL, completed: @escaping RequestHandler) {
        URLSession.shared.configuration.timeoutIntervalForRequest = 15 // default = 60's
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            var returnError = error
            var returnData: Data?
            
            defer {
               completed(returnData, returnError)
            }
            
            // handle network errors
            guard let data = data, error == nil else {
                print("Network error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            // parsing JSON data
            guard
                let json = try? JSONSerialization.jsonObject(with: data),
                let dictionary = json as? [String: Any],
                let status = dictionary["status"] as? String
                else {
                    print("JSON parsing failed")
                    return
            }
            // get json data
            if status.isEqual("ok") {
                // change json dictionary to Data
                returnData = try? JSONSerialization.data(withJSONObject: dictionary["data"] as Any)
            }
        }
        
        task.resume()
    }
    
    // constants
    
    private struct Constants {
        //static let token = "c01075aa024f264013e856b80a34fc1d526b404f"
        //static let httpPrefix = "https://api.waqi.info/feed"
        //static let server = "http://127.0.0.1"
        static let server = "http://108.61.200.158"
        static let getstationbyipurl = "https://api.waqi.info/feed/here/?token=c01075aa024f264013e856b80a34fc1d526b404f"
    }

}
