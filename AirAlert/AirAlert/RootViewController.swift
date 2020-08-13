//
//  RootViewController.swift
//  AirAlert
//
//  Created by hyf on 2019/4/18.
//  Copyright © 2019年 Deng Junqiang. All rights reserved.
//

import UIKit
//import CoreLocation
import UserNotifications

class RootViewController: UIViewController {

    // MARK: - outlets
    
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var updatedTimeLabel: UILabel!
    @IBOutlet weak var aplLabel: UILabel!
    @IBOutlet weak var aqiLabel: UILabel!
    
    // location manager
    //var locationManager: CLLocationManager!
    
  
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         // set navigation bar transparent -- is to set a "NULL" image
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        */
        
        //register for UIApplicationWillEnterForeground Notification
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground(notification:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        /* 点击label，如何实现页面跳转？
         
         way 1 - 点击label，跳转到指定页面
         1）添加label的点击手势
         2）在事件中跳转到页面
         
         way 2 - 点击label，执行segue
         1）通过顶端小按钮，form间建立segue；
         2）添加label的点击手势
         3）在label点击事件中执行segue
         */
       
        // register tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(singleTapHandler(_:)))
        tapGesture.numberOfTapsRequired = 1
        aplLabel.isUserInteractionEnabled = true
        aplLabel.addGestureRecognizer(tapGesture)
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(singleTapHandler(_:)))
        tapGesture2.numberOfTapsRequired = 1
        aqiLabel.isUserInteractionEnabled = true
        aqiLabel.addGestureRecognizer(tapGesture2)
        
        // register swipe gesture 滑动换页
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(singleTapHandler(_:)))
        leftSwipeGesture.direction = UISwipeGestureRecognizer.Direction.left
        view.addGestureRecognizer(leftSwipeGesture)
        
    
        // add emitter layer to viwe
        initEmitterLayer()
        
        /*
         首次安装定位处理
         1) 通过Location定位，获取airdata，刷新界面
         2）如果用户禁用location功能
            2.1）使用IP定位获取StationID
            2.2）IP定位失败，使用默认位置3304
            2.3）获取airdata， 刷新界面
         */
        
        // init monitoring station
        if (Settings.sharedInstance.stationSelected == false) {//while init App
            Settings.sharedInstance.stationSelected = true
            print("首次使用App，正在获取位置信息")
            
            // register for Location Authorization Denied，
            // 注册用户禁用地理位置消息的通知；当用户禁用获取地理位置功能，触发通知函数
            NotificationCenter.default.addObserver(forName: .UserDeniedLocationAuthorization, object: nil, queue: OperationQueue.main) { (Notification) in
                self.requestAirDataByIP()
                
                print("received notification -- UserDeniedLocationAuthorization")
                NotificationCenter.default.removeObserver(self, name: .UserDeniedLocationAuthorization, object: nil)
            }
            
            //  通过物理定位，获取airdata, 刷新界面
            requestAirDataByLocation()// get geo base on location
            
            return
        }
        
        //refresh Air Data & UI
        print("fetchairdata")
        fetchAirData()
        
    }
    
    // MARK: - tap gesture function
    
    @objc func singleTapHandler(_ sender: UITapGestureRecognizer) {
        //way 2
        self.performSegue(withIdentifier: "RootViewSegueIdentifier", sender: sender)
        
        //way 1
        /*let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let threeVC = storyboard.instantiateViewController(withIdentifier: "AqiTabBarStoryboardID") as? AqiTabBarController else {  return }
        self.navigationController?.pushViewController(threeVC, animated: true)*/
    }
    
    //MARK: - location services
    
    func requestAirDataByIP() {
        print("requestStationIDByIp")
        AirRequest.sharedInstance.getStationIDBaseonIP { (data, error) in
            DispatchQueue.main.async {
                
                defer {
                    self.fetchAirData()
                }
                
                // handle errors
                guard let data = data, error == nil else {
                    print(error ?? "getCityBaseonIP.error")
                    return
                }
                
                // get station id
                guard
                    let json = try? JSONSerialization.jsonObject(with: data),
                    let dictionary = json as? [String: Any],
                    let stationid = dictionary["idx"] as? Int
                    else {
                        print("JSON parsing failed: can not find station")
                        return
                }
                
                Settings.sharedInstance.stationID = stationid
                print(stationid)
                
            }
            
        }
        
    }
    
    
    func requestAirDataByLocation() {
        print("request location")
        // 定位认证 requestWhenInUseAuthorization()
        AirLocationManager.shareInstance.requestLocation { (location, error) in
            print("经度 \(location?.coordinate.longitude ?? 0.0)")
            print("纬度 \(location?.coordinate.latitude ?? 0.0)")
            print("error \(String(describing: error))")
            if let longitude = location?.coordinate.longitude,
                let latitude = location?.coordinate.latitude {
                self.fetchAirDataWithGeo(latitude: latitude, longitude: longitude)
            }
        }
    }
    
    // MARK: - update UI when app enter foreground from background
    
    @objc private func applicationWillEnterForeground(notification: NSNotification) {
        
        // check weather there are new data
        fetchAirData()
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()  //删除已经递送的通知
    }
    
    // MARK: - refresh data
    // call by changeCityView
    @objc func refreshData() {
        fetchAirData()
    }
    
    // refresh UI
    
    func refreshUI() {
        // update navigation item
        (navigationItem.titleView as? UIButton)?.setTitle(airData?.city?.localizedName(), for: .normal)
        // update labels
        weatherLabel.text = airData?.iaqi?.getWeatherInfo()
        updatedTimeLabel.text = airData?.time?.getUpdatedTimeString()
        if let aqi = airData?.aqi {
            AqiTable.setAplLabelAsLegend(aqi: aqi, label: aplLabel)
            AqiTable.setAqiLabelAsLegend(aqi: aqi, label: aqiLabel)
        }
        
        // update emitter layer
        updateEmitterLayer()
    }
    
    // MARK: - Data Fetching/Updating
    fileprivate func fetchAirData() {
        if (airData == nil) || (airData?.OutOfDate() == true) {
            
            AirRequest.sharedInstance.getAirData(stationID: Settings.sharedInstance.stationID) { (data, error) in
                DispatchQueue.main.async {
                    // handle errors
                    guard let data = data, error == nil else {
                        print(error ?? "fetchAirData.error")
                        return
                    }
                    // decode Data to AirData
                    if let test = try? JSONDecoder().decode(AirData.self, from: data) {
                        airData = test
                    }
                    self.refreshUI()
                }
            }
        } else {
            refreshUI()// refreshUI even if AirData not be changed
        }
    }
    
    
    fileprivate func fetchAirDataWithGeo(latitude: Double, longitude: Double) {
        AirRequest.sharedInstance.getAirDataWithGeo(latitude: latitude, longitude: longitude) { (data, error) in
            DispatchQueue.main.async {
                // handle errors
                guard let data = data, error == nil else {
                    print(error ?? "fetchAirDataWithGeo.error")
                    return
                }
                // decode Data to AirData
                if let test = try? JSONDecoder().decode(AirData.self, from: data) {
                    airData = test
                    Settings.sharedInstance.stationID = airData?.idx ?? -1
                }
                self.refreshUI()
                
            }
        }
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
        let pm25count = airData?.iaqi?.pm25
        cell_pm25.birthRate = 2 * (pm25count ?? 0)
        //cell_pm25.lifetime = cell_pm25.lifetime
        cell_pm25.scale = 0.1
        cell_pm25.scaleRange = cell_pm25.scale * 0.2
        
        let pm10count = airData?.iaqi?.pm10
        cell_pm10.birthRate = pm10count ?? 0
        cell_pm10.scale = 0.2
        cell_pm10.scaleRange = cell_pm10.scale * 0.2
        
        emitter.emitterCells?.removeAll()
        emitter.emitterCells = [cell_pm25, cell_pm10]
        //print("update emitter layer")
    }
}
