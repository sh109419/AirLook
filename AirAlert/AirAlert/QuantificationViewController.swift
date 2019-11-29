//
//  QuantificationViewController.swift
//  AirAlert
//
//  Created by hyf on 2019/9/5.
//  Copyright © 2019 Deng Junqiang. All rights reserved.
//

/*
 "A sesame seed weighs approximately %.3f grams." = "一粒芝麻重量约有%.3f克";
 "People inhale %d cubic meters of air per day." = "我们每天吸入的空气约为%d立方米";
 "The pollution particles you inhale today are as heavy as %@ sesame seeds." = "你今天吸入的空气污染颗粒约为%@粒芝麻";
 Measure how much dust you eat
 */

import UIKit

class QuantificationViewController: UIViewController {

    @IBOutlet weak var quantificationLabel: UILabel!
    @IBOutlet weak var oneDayAirLabel: UILabel!
    @IBOutlet weak var sesameWeightLabel: UILabel!
    
    @IBOutlet weak var pm10Label: UILabel!
    @IBOutlet weak var pm25Label: UILabel!
    
    @IBOutlet weak var pm25Slider: UISlider!
    @IBOutlet weak var pm10Slider: UISlider!
    
    private var weight: Float = 0.0 {
        didSet {
            //print(weight)
            quantificationLabel.text = String(format: "The pollution particles you inhale today are as heavy as %@ sesame seeds.".localized, cleanFloatZero(number: weight))
        }
    }
    
    // 参数格式 %.1f
    func cleanFloatZero(number: Float) -> String {
        
        let str = String(format: "%.1f", number)
        
            if ("0" == str.suffix(1)) {
               // return testNumber[0..<testNumber.count-2]
                
                let endIndex =  str.index(str.endIndex, offsetBy: -2)
                return String(str[..<endIndex])
                
            } else {
                return str
            }
      
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
         监控滑块的数值变化
         */
        pm10Slider.addTarget(self, action: #selector(valueChange(_:)), for: UIControl.Event.valueChanged)
        pm25Slider.addTarget(self, action: #selector(valueChange(_:)), for: UIControl.Event.valueChanged)
        
        // update slider value
        var pm25Value = airData?.iaqi?.pm25 ?? 0
        if pm25Value < 0 { pm25Value = 0 }
        if pm25Value > 300 { pm25Value = 300 }
        var pm10Value = airData?.iaqi?.pm10 ?? 0
        if pm10Value < 0 { pm10Value = 0 }
        if pm10Value > 300 { pm10Value = 300 }
        
        pm25Slider.value = pm25Value
        pm10Slider.value = pm10Value
        pm25Label.text = String(format: "%.0f", pm25Value)
        pm10Label.text = String(format: "%.0f", pm10Value)
        
        // set label
        sesameWeightLabel.text = "    " + String(format: "A sesame seed weighs approximately %.3f grams.".localized, Constants.sesameWeight)
        oneDayAirLabel.text = "    " + String(format: "People inhale about %d cubic meters of air per day.".localized, Constants.onedayAir)
        
        weight = (pm25Slider.value + pm10Slider.value) * Float(Constants.onedayAir) * 0.000001 / Constants.sesameWeight
        
    }
    
    /**
     滑块的取值变化
     */
    @objc func valueChange(_ slider: UISlider) -> Void {
        pm25Label.text = String(format: "%.0f", pm25Slider.value)
        pm10Label.text = String(format: "%.0f", pm10Slider.value)
        
        weight = (pm25Slider.value + pm10Slider.value) * Float(Constants.onedayAir) * 0.000001 / Constants.sesameWeight
    }
    
    private struct Constants {
        static let sesameWeight: Float = 0.002
        static let onedayAir = 10
    }
    
}

