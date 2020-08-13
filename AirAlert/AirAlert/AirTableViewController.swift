//
//  AirTableViewController.swift
//  AirAlert
//
//  Created by hyf on 2018/8/15.
//  Copyright © 2018年 Deng Junqiang. All rights reserved.
//

import UIKit
import os.log
//import UserNotifications
import MapKit

class MapAnnotation: MKPointAnnotation {
    var aqi: Int?
}

class AirTableViewController: UITableViewController {
    
    /* nearest cites */
    
    private var nearestList: NearestList = [] {
        didSet {
            initMapView()
            mapCellView.addSubview(self.mapView)
            tableView.reloadData()
        }
    }

    lazy var mapView: MKMapView = {
        let frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: self.mapCellView.frame.height)
        let mapView = MKMapView(frame: frame)
        
        //mapView.userTrackingMode = .follow
        mapView.mapType = .standard
        mapView.isScrollEnabled = true
        mapView.isZoomEnabled = true
        //mapView.showsUserLocation = true
        mapView.delegate = self
        
        return mapView
    } ()
    
    func initMapView() {
        if nearestList.count < 1 { return }
        
        // set map region
        
        let centerGeo = nearestList[0]
        
        let span = MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)
        let center = CLLocation(latitude: CLLocationDegrees(centerGeo.latitude ?? 0.0),
                                longitude: CLLocationDegrees(centerGeo.longitude ?? 0.0))
        let region = MKCoordinateRegion(center: center.coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
        
        // add annotaions
        for nearest in nearestList {
            let location = CLLocation(latitude: CLLocationDegrees(nearest.latitude ?? 0.0),
                                      longitude: CLLocationDegrees(nearest.longitude ?? 0.0))
            
            let pointAnnotation = MapAnnotation()
            pointAnnotation.coordinate = location.coordinate
            pointAnnotation.title = nearest.name
            pointAnnotation.aqi = nearest.aqi
            
            self.mapView.addAnnotation(pointAnnotation)
        }
    }
    
    static let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "AirTableViewController")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register daily forecast cell, cellstyle = custom
        self.tableView.register(UINib.init(nibName: "AirTableViewDailyForecastCell", bundle: nil), forCellReuseIdentifier: "AirTableViewDailyForecastCell")
        
        // register nearest cities cell , unique indentifier is defined here
        self.tableView.register(UINib.init(nibName: "StationsTableViewCell", bundle: nil), forCellReuseIdentifier: "StationsTableViewCell")
        
        if nearestOfAirData.count > 0 {
            nearestList = nearestOfAirData
        } else {
            AirRequest.sharedInstance.getNearestList(airdataID: (airData?.idx)!) { (data, error) in
                DispatchQueue.main.async {
                    // handle errors
                    guard let data = data, error == nil else {
                        print(error ?? "getNearestList.error")
                        return
                    }
                    // decode Data to nearest list
                    if let test = try? JSONDecoder().decode(NearestList.self, from: data) {
                        self.nearestList = test
                        nearestOfAirData = test // save as global variable;
                    }
                }
            }
        }
        /*//add refresh function
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshData), for: UIControlEvents.valueChanged)
        refreshControl?.attributedTitle = NSAttributedString(string: "release to refresh".localized)
        tableView.addSubview(refreshControl!)*/
        
        aqiDetails = airData?.iaqi?.getIAqiDetails()
        
        //refresh UI
        refreshUI()
    }
    
    // iaqi
    private var aqiDetails:  [IAqiDetail]?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // update self-defined attentions if changed
        if let aqi = airData?.aqi {
            let temp = AqiTable.getSelfdefinedAttentions(aqi: aqi)
            if (temp != healthImpLabel.text) {
                //print("health changed")
                healthImpLabel.text = temp
                tableView.reloadData()
            }
        }

    }
  
    
    
    // MARK: - outlets
    
   // @IBOutlet weak var weatherLabel: UILabel!
   // @IBOutlet weak var updatedTimeLabel: UILabel!
    @IBOutlet weak var aplLabel: UILabel!
    @IBOutlet weak var aqiLabel: UILabel!
    @IBOutlet weak var healthImpLabel: UILabel!
    // daily aqi
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var todayAqiRangeLabel: UILabel!
    // iaqi
    @IBOutlet weak var iaqiCollectionView: UICollectionView!
    // 24 hour aqi
    @IBOutlet weak var aqi24HourCollectionView: UICollectionView!
    // nearest map
    @IBOutlet weak var mapCellView: UIView!
    
    // refresh UI
    func refreshUI() {
        // update navigation item
        (navigationItem.titleView as? UIButton)?.setTitle(airData?.city?.localizedName(), for: .normal)
        // update cells
        
        /*
         set label.backgroundColor failed,
         because the cell have a white background by default,
         if you want to change the background color, do so in the
         tableView: willDisplayCell
 
         */
        if let aqi = airData?.aqi {
            AqiTable.setAplLabelAsLegend(aqi: aqi, label: aplLabel)
            AqiTable.setAqiLabelAsLegend(aqi: aqi, label: aqiLabel)
            healthImpLabel.text = AqiTable.getSelfdefinedAttentions(aqi: aqi)
            // iaqi
            iaqiCollectionView.dataSource = self
            iaqiCollectionView.delegate = self
            iaqiCollectionView.reloadData()
        }
        if (airData?.forecast_aqi?.active() == true) {
            // daily aqi
            todayLabel.text = airData?.forecast_aqi?.getDayofWeek(dayIndex: 0)
            if (todayLabel.text != nil) {
                todayLabel.text = todayLabel.text! + " " + "today".localized
            }
            todayAqiRangeLabel.text = airData?.forecast_aqi?.getAqiRangeString(dayIndex: 0)
            // 24hour aqi
            aqi24HourCollectionView.dataSource = self
            aqi24HourCollectionView.delegate = self
            aqi24HourCollectionView.reloadData()
            
        }
       
        tableView.reloadData()// dynamic adjust the cell height for "Health Implications"
    }
    
   
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        tableView.separatorStyle = .singleLine
        
        if (section == 0) {
            if (airData?.forecast_aqi?.active() == true) {
                return Constants.rowCountWithoutForecast + 1 + (airData?.forecast_aqi?.daily?.count)! //1 for 24 hour forecast
            }
            return Constants.rowCountWithoutForecast
        } else if (section == 1) {
            return nearestList.count + 1 // stations + label
        } else {
            return nearestList.count > 0 ? 1 : 0
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) {
            // dynamic cells
            if indexPath.row >= Constants.forecast2ndDayRow {
                let dayIndex = indexPath.row - Constants.forecast2ndDayRow + 1
                let cell: AirTableViewDailyForecastCell = tableView.dequeueReusableCell(withIdentifier: "AirTableViewDailyForecastCell", for: indexPath) as! AirTableViewDailyForecastCell
                cell.selectionStyle = .none
                cell.timeLabel.text = airData?.forecast_aqi?.getDayofWeek(dayIndex: dayIndex)
                cell.aqiRangeLabel.text = airData?.forecast_aqi?.getAqiRangeString(dayIndex: dayIndex)
                if let max = airData?.forecast_aqi?.getMaxDailyAqi(dayIndex: dayIndex) {
                    let imageColor = AqiTable.getAqiImageColor(aqi: max)
                    let newImage = cell.aqiImage?.image?.imageWithTintColor(color: imageColor)
                    cell.aqiImage.image = newImage
                    //set storyboard.autoresizing to show image in center of row
                }
                
                return cell
            }
        }
        
        if (indexPath.section == 1) {
            // dynamic cells
            if indexPath.row >= 1 {
                let stationIndex = indexPath.row - 1
                let nearest = nearestList[stationIndex]
                let cell: StationsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "StationsTableViewCell", for: indexPath) as! StationsTableViewCell
                cell.selectionStyle = .none
                cell.stationLabel.text = nearest.name
                AqiTable.setAqiLabelAsLegend(aqi: nearest.aqi!, label: cell.aqiLabel)
                
                return cell
            }
        }
        
        // static cells
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    // show separator line
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            if (indexPath.row == Constants.forecastTodayRow)
                || (indexPath.row == Constants.forecast24HourRow)
                || (indexPath.row == Constants.iaqiRow) {
                // || (indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1){
                // do nothing
            } else {
                cell.separatorInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: CGFloat(MAXFLOAT))//指定某行分割线隐藏
                
                // for update background color
                if indexPath.row == Constants.aqiRow {
                    if let aqi = airData?.aqi {
                        AqiTable.setAqiLabelAsLegend(aqi: aqi, label: aqiLabel)
                    }
                }
            }
        }
        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                // || (indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1){
                // do nothing
            } else {
                cell.separatorInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: CGFloat(MAXFLOAT))//指定某行分割线隐藏
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0) {
            if (indexPath.row == Constants.healthImplicationsRow) {
                return HealthImplicationsHeight() + 44  // 2 lines for break
            } else if (indexPath.row >= Constants.forecast2ndDayRow) {
                return self.tableView.rowHeight
            }
        }
        if (indexPath.section == 1) {
            if (indexPath.row >= 1) {
                return self.tableView.rowHeight
            }
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    // estimated row height
    private func HealthImplicationsHeight() -> CGFloat {
        let fixedWidth = tableView.contentSize.width - tableView.layoutMargins.left - tableView.layoutMargins.right
        let size = CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude)
        let constraint = healthImpLabel.sizeThatFits(size)
        return constraint.height 
    }
    
    //当覆盖了静态的cell数据源方法时需要提供一个代理方法。
    //因为数据源对新加进来的cell一无所知，所以要使用这个代理方法
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if (indexPath.section == 0) {
            if (indexPath.row >= Constants.forecast2ndDayRow)  {
                let newIndexPath = IndexPath(row: 0, section: indexPath.section)
                return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
            }
        }
        if (indexPath.section == 1) {
            if (indexPath.row >= 1)  {
                let newIndexPath = IndexPath(row: 0, section: indexPath.section)
                return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
            }
        }
        return super.tableView(tableView, indentationLevelForRowAt: indexPath)
    }
    
    // constants
    
    private struct Constants {
        static let rowCountWithoutForecast = 4
        // index
        static let aqiRow = 1
        static let iaqiRow = 2
        static let healthImplicationsRow = 3
        // forecast
        static let forecastTodayRow = 4
        static let forecast24HourRow = 5
        static let forecast2ndDayRow = 6
    }
    
    
}



// UICollectionViewDataSource

extension AirTableViewController: UICollectionViewDataSource {
    // bing datasouce to viewcontroller, else it does not work
    
    // tag: 1 24hourcell
    // tag: 2 iaqicell
    
    // count
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let tagValue = collectionView.tag
        if (tagValue == 1) {
            return airData?.forecast_aqi?.hour24?.count ?? 0
        } else {
            return aqiDetails?.count ?? 0
        }
    }
    
    //cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tagValue = collectionView.tag
        if (tagValue == 2) {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "iaqiCell", for: indexPath) as? IAqiCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            if let key = aqiDetails?[indexPath.row].key {
                if key == airData?.dominentpol {
                    //cell.iaqiNameLabel.font = UIFont.boldSystemFont(ofSize: 20)
                    cell.iaqiNameLabel.textColor = UIColor.blue
                }
                cell.iaqiNameLabel.text = key.uppercased()
                if cell.iaqiNameLabel.text == "PM25" {
                    cell.iaqiNameLabel.text = "PM2.5"
                }
            }
            
            if let aqi = aqiDetails?[indexPath.row].aqi {
                AqiTable.setAqiLabelAsLegend(aqi: aqi, label: cell.iaqiValueLabel)
            }
            
            return cell
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "24hourCell", for: indexPath) as? Aqi24HourCollectionViewCell else {
            return UICollectionViewCell()
        }
        let index = indexPath.row
        cell.timeLabel.text = airData?.forecast_aqi?.getHourString(index: index)
        if index == 0 {
            cell.timeLabel.text = "Now".localized
        }
        if let hour = airData?.forecast_aqi?.hour24 {
            if hour[index].count == 2 {// avoid index out of range
                let min = hour[index][0]
                let max = hour[index][1]
                AqiTable.setAqiLabelAsLegend(aqi: min, label: cell.minLabel)
                AqiTable.setAqiLabelAsLegend(aqi: max, label: cell.maxLabel)
            }
        }
       
        return cell
    }
}

// UICollectionViewDelegate

extension AirTableViewController: UICollectionViewDelegate {
    //bing delegate to viewcontroller
    
    //func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      //  buttonOnClick(indexPath.row)
    //}
}

extension UIImage {
    
    /// 更改图片颜色
    public func imageWithTintColor(color : UIColor) -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        color.setFill()
        let bounds = CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height)
        UIRectFill(bounds)
        self.draw(in: bounds, blendMode: CGBlendMode.destinationIn, alpha: 1.0)
        
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage!
    }
    
    
}

// map view

extension AirTableViewController: MKMapViewDelegate {
    
    // self-define annotation view
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MKPinAnnotationView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if (annotationView == nil) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            if let aqi = (annotation as? MapAnnotation)?.aqi {
                annotationView?.image = AqiTable.getAqiImageAsLegend(aqi: aqi)
            }
        } else {
            //annotationView!.annotation = annotation
        }
        return annotationView
    }
    
}
