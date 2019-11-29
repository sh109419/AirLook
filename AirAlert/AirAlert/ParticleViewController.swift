//
//  ParticulateViewController.swift
//  AirAlert
//
//  Created by hyf on 2019/3/27.
//  Copyright © 2019年 Deng Junqiang. All rights reserved.
//
/*

 //你的每一口呼吸，都有多少的PM2.5
 //假设pm2.5平均为 150，就是150微克每立方米，人吸一口气300mL，0.0003立方米。
 //一口会吸入多少空气中漂浮的微粒：150*0.0003=0.045微克。
 
每一口空气重量是多少？pm2.5占比多少？
 
 你今天吸入的空气污染颗粒约为3粒芝麻
 一粒芝麻重量约有0.00000201kg，0.002克
 A sesame seed weighs approximately 0.00364 grams.
 如果24小时的pm2.5浓度都按500微克来算的话，按全天呼入十立方米空气来算应该吸入的是500微克x10=5000微克=5毫克。
 How much pollution do we breathe every day?
 That totals about 11,000 liters of air per day.
 */

import UIKit

class ParticleViewController: UIViewController {
    
    @IBOutlet weak var pm10Label: UILabel!
    @IBOutlet weak var pm25Label: UILabel!
    
    @IBOutlet weak var pm25Slider: UISlider!
    @IBOutlet weak var pm10Slider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //let bjViewImage = UIImage.init(named: "scenery")
        // 设置 topView 的背景图片
        //view.layer.contents = bjViewImage?.cgImage
        
        
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
        
        // add emitter layer to viwe
        initEmitterLayer()
        updateEmitterLayer()
        
    }
    
    /**
     滑块的取值变化
     */
    @objc func valueChange(_ slider: UISlider) -> Void {
        pm25Label.text = String(format: "%.0f", pm25Slider.value)
        pm10Label.text = String(format: "%.0f", pm10Slider.value)
        updateEmitterLayer()
    }
    
    // MARK:- emitter functions
    
    let cell_pm10 = CAEmitterCell()
    let cell_pm25 = CAEmitterCell()
    let emitter = CAEmitterLayer()
    
    fileprivate func initEmitterCell(cell: CAEmitterCell) {
        // public for pm2.5 & pm10
        cell.contents = UIImage(named: "asteroid2.png")?.cgImage
        //cell.birthRate = 150.0
        cell.lifetime = 2.5
        cell.lifetimeRange = 1.0
        cell.xAcceleration = 5.0
        cell.yAcceleration = 5.0
        cell.velocity = 8.0
        cell.emissionLongitude = .pi
        cell.emissionRange = .pi * 0.25
        //cell.scale = 0.8
        //cell.scaleRange = cell.scale * 0.2
        //cell.scaleSpeed = -0.1
        cell.alphaRange = 0.35
        cell.alphaSpeed = -0.15
        cell.spinRange = .pi
        
    }
    
    fileprivate func initEmitterLayer() {
        
        emitter.frame = view.bounds
        emitter.emitterSize = view.bounds.size
        emitter.emitterPosition = view.center
        emitter.emitterShape = CAEmitterLayerEmitterShape.cuboid
        emitter.emitterDepth = 25.0
        //emitter.renderMode =  kCAEmitterLayerBackToFront
        emitter.preservesDepth = true//3d效果，cell图片变小
        view.layer.addSublayer(emitter)
        
        initEmitterCell(cell: cell_pm10)
        initEmitterCell(cell: cell_pm25)
    }
    
    fileprivate  func updateEmitterLayer() {
        let pm25count = pm25Slider.value
        cell_pm25.birthRate = 2 * (pm25count )
        //cell_pm25.lifetime = cell_pm25.lifetime
        cell_pm25.scale = 0.1
        cell_pm25.scaleRange = cell_pm25.scale * 0.2
        
        let pm10count = pm10Slider.value
        cell_pm10.birthRate = pm10count
        cell_pm10.scale = 0.2
        cell_pm10.scaleRange = cell_pm10.scale * 0.2
        
        // func resetEmitterCells()
        emitter.emitterCells = nil
        emitter.emitterCells = [cell_pm10, cell_pm25]
    }
           
}
