//
//  TodayViewController.swift
//  AirWidget
//
//  Created by hyf on 2019/2/5.
//  Copyright © 2019年 Deng Junqiang. All rights reserved.
//

/*
 
 Target Membership:
 
    AirData.swift
    AirRequest.swift
    AirCommon.swift
    Settings.swift
    AirLanguageHelper.swift
    Localizable.strings
 
 */

/*
 
 the language of widget is changed with iOS language
 
 */

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var aqiLabel: UILabel!
    @IBOutlet weak var aplLabel: UILabel!
    @IBOutlet weak var stationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        // register tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(singleTapHandler(_:)))
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture);
       
        // refresh data here
        fetchAirData()
        
    }
    
    @objc func singleTapHandler(_ sender: UITapGestureRecognizer) {
        let url = URL(string: "AirAlert://")!
        extensionContext?.open(url, completionHandler: { (completed) in
            print("open url")
        })
    }
    
    
    // MARKS: Data Fetching, Updating & restore
    
    // 1. get air data from group share store
    // 2. get air data from url
    // 3. update air data on group share store
    
    fileprivate func fetchAirData() {
        // 1.  read group shared data
        var airData = AirData()
        if (airData == nil) { return }
        
        refreshUI(airdata: airData!)
        
        
        if  (airData?.OutOfDate4Widget() == true) {
            // 2.
            AirRequest.sharedInstance.getAirData(stationID: (airData?.idx)!) { (data, error) in
                DispatchQueue.main.async {
                    
                    // handle errors
                    guard let data = data, error == nil else {
                        print(error ?? "fetchAirData.error")
                        return
                    }
                    // decode Data to AirData
                    if let test = try? JSONDecoder().decode(AirData.self, from: data) {
                        //compare test with airData
                        if test.time?.timeStr == airData?.time?.timeStr { return }
                        print("air data changed")
                        airData = test
                        //3.
                        airData?.Save()
                        // station unchanged here
                        //Settings.sharedInstance.stationID = (airData?.idx)!
                        self.refreshUI(airdata: airData!)
                        
                    }
                }
            }
        }
    }
    
    func refreshUI(airdata: AirData) {
        // get phone language
        //用户在手机系统设置里设置的语言。返回一个数组: ["zh-Hans-CN", “en"]
        let appLanguages = Locale.preferredLanguages
        var phoneLanguage = "en"
        if appLanguages.count > 0 {
            phoneLanguage = appLanguages[0]
            if phoneLanguage.hasPrefix("zh-Hans") {
                phoneLanguage = "zh-Hans"
            }
        }
        
        stationLabel.text = (phoneLanguage == "zh-Hans") ? airdata.city?.name2 : airdata.city?.name
        
        let aqi = airdata.aqi ?? 0
        AqiTable.setAqiLabelAsLegend(aqi: aqi, label: aqiLabel)
        AqiTable.setAplLabelAsLegend(aqi: aqi, label: aplLabel)
    }
    
}
