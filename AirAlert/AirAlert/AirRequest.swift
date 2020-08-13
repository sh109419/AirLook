//
//  Request.swift
//  AirAlert
//
//  Created by hyf on 2018/8/17.
//  Copyright © 2018年 Deng Junqiang. All rights reserved.
//

import Foundation


/*
 ### API List
 
 * localhost/AirLook/setting/newToken/token
 * localhost/AirLook/setting/changeStationID/3303/token
 * localhost/AirLook/setting/changeAlertLevel/2/token
 * localhost/AirLook/setting/changeRecoveryEnabled/false/token
 * localhost/AirLook/airdata/id/3303
 * localhost/AirLook/airdata/location/latitude;longitude
 * localhost/AirLook/nearest/id/3303
 * localhost/AirLook/search/city/shanghai
 
 */

class AirRequest: NSObject {
    
    static let sharedInstance = AirRequest()
    
    // Completion block for fetch Json Response.
    // { status: ok, data: {} }
    public typealias RequestHandler = (Data?, Error?) -> Swift.Void
    
    
    //MARK: - request data from network
    
    // new device token
    //localhost/api/setting/newToken/token
    func newToken(completed: @escaping RequestHandler) {
        if let url = URL(string: "\(Constants.server)/setting/newToken/\(Settings.sharedInstance.deviceToken)") {
            print(url)
            performRequest(url: url) { (data,error) in completed(data, error) }
        }
    }
    
    // update settings
    // localhost/api/setting/changestationID/3303/token
    func changeStationID(completed: @escaping RequestHandler) {
        if let url = URL(string: "\(Constants.server)/setting/changeStationID/\(Settings.sharedInstance.stationID)/\(Settings.sharedInstance.deviceToken)") {
            print(url)
            performRequest(url: url) { (data,error) in completed(data, error) }
        }
    }
    
    // localhost/api/setting/changealertLevel/2/token
    func changeAlertLevel(completed: @escaping RequestHandler) {
        if let url = URL(string: "\(Constants.server)/setting/changeAlertLevel/\(Settings.sharedInstance.alertLevel)/\(Settings.sharedInstance.deviceToken)") {
            print(url)
            performRequest(url: url) { (data,error) in completed(data, error) }
        }
    }
    
    // localhost/api/setting/changerecoveryEnabled/false/token
    func changeRecoveryEnabled(completed: @escaping RequestHandler) {
        if let url = URL(string: "\(Constants.server)/setting/changeRecoveryEnabled/\(Settings.sharedInstance.recoveryEnabled)/\(Settings.sharedInstance.deviceToken)") {
            print(url)
            performRequest(url: url) { (data,error) in completed(data, error) }
        }
    }
    
    // localhost/api/airdata/id/3303
    func getAirData(stationID: Int, completed: @escaping RequestHandler) {
        if let url = URL(string: "\(Constants.server)/airdata/id/\(stationID)") {
            print(url)
            performRequest(url: url) { (data,error) in completed(data, error) }
        }
    }
 
    // localhost/api/airdata/location/latitude;longitude
    func getAirDataWithGeo(latitude: Double, longitude: Double, completed: @escaping RequestHandler) {
      if let url = URL(string: "\(Constants.server)/airdata/location/\(latitude);\(longitude)") {
        print(url)
        performRequest(url: url) { data, error in completed(data, error) }
        }
    }
    
    
    // localhost/api/search/city/shanghai
    func getSearchData(keyword: String, completed: @escaping RequestHandler) {
        // search request
       
        let urlStr = "\(Constants.server)/search/city/\(keyword)"
        // allow search by Chinese
        let encodedUrl = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        if let url = URL(string: encodedUrl ?? "") {
            print(url)
            performRequest(url: url) { data, error in completed(data, error) }
        }
    }
    
    // get Station id base on IP
    func getStationIDBaseonIP(completed: @escaping RequestHandler) {
        if let url = URL(string: Constants.getstationbyipurl) {
            print(url)
            performRequest(url: url) { (data,error) in completed(data, error) }
        }
    }
    
    // localhost/api/nearest/id/3303
    func getNearestList(airdataID: Int, completed: @escaping RequestHandler) {
        // nearest request
        if let url = URL(string: "\(Constants.server)/nearest/id/\(airdataID)") {
            print(url)
            performRequest(url: url) { data, error in completed(data, error) }
        }
    }
    
    private func performRequest(url: URL, completed: @escaping RequestHandler) {
        //URLSession.shared.configuration.timeoutIntervalForRequest = 15 // default = 60's
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
                    print("JSON parsing failed-\(data)")
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
        //static let server = "http://192.168.1.8/airlook/api"
        static let server = "http://108.61.200.158/AirLook/api"
        static let getstationbyipurl = "https://api.waqi.info/feed/here/?token=c01075aa024f264013e856b80a34fc1d526b404f"
    }

}
