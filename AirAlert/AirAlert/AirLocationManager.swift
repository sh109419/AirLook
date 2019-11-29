//
//  LocationManager.swift
//  AirAlert
//
//  Created by hyf on 2018/9/18.
//  Copyright © 2018年 Deng Junqiang. All rights reserved.
//

import Foundation
import CoreLocation

class AirLocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shareInstance = AirLocationManager()
    
    typealias LocationCallBack = (CLLocation?, Error?) -> Swift.Void
    var callback: LocationCallBack?
     
    lazy var manager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
    func requestLocation(resultBack: @escaping LocationCallBack) {
        // set call back
        callback = resultBack
        
        if CLLocationManager.locationServicesEnabled() {
            // MARK: - Authorization
            manager.requestWhenInUseAuthorization()
            // start locating
            manager.startUpdatingLocation()
        } else {
            print("location services disabled")
        }
    }
    
    // MARK: - Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("get location")
        if (locations.count > 0) {
            let location = locations.last!
            let lat = Double(String(format: "%.1f", location.coordinate.latitude))
            let long = Double(String(format: "%.1f", location.coordinate.longitude))
            print("longitude:\(long!)")
            print("latitude:\(lat!)")
            
            callback?(location, nil)
            
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        print(error ?? "hello")
        callback?(nil, error)
        manager.stopUpdatingLocation()
    }
    
    // used to get airdata by ip, when location disabled at INIT
    var LocationNotDetermined = false
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //print(status.rawValue)
        switch status {
        case .notDetermined:
            LocationNotDetermined = true
            break
        case .denied:
            // if .notDeterminded, run requestWhenInUseAuthorization()
            // pop Authorization dialog
            // user click 'cancel'
            // get airdata by IP
            if LocationNotDetermined {
                print("user denied location authorization")
                LocationNotDetermined = false
                NotificationCenter.default.post(name: .UserDeniedLocationAuthorization, object: nil)
            }
            break
        default:
            break
        }
    }

}

extension NSNotification.Name {
    
    public static let UserDeniedLocationAuthorization: NSNotification.Name = NSNotification.Name(rawValue: "UserDeniedLocationAuthorization")
}

