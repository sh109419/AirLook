//
//  ChangeCityTableViewController.swift
//  AirAlert
//
//  Created by hyf on 2018/9/14.
//  Copyright © 2018年 Deng Junqiang. All rights reserved.
//

import UIKit
import CoreLocation

class ChangeCityTableViewController: UITableViewController, UITextFieldDelegate {
    
   
    // common cities
    let cityArray = [("Beijing".localized, 3303),
                     ("Shanghai".localized, 3304),
                     ("Guangzhou".localized, 3305),
                     ("Chengdu".localized, 3306),
                     ("Shenyang".localized, 496),
                     //("HongKong", 3308),
                     //("Hangzhou", 1439),
                     //("Suzhou", 1489),
                     //("Nanjing", 1485),
        
                     //("Chongqing", 1453),
                     //("Xiamen", 1501),
                     //("Tianjin", 1452),
                     //("Xian", 1569),       // the data are out of date, WHY?
                     //("Dalian", 1474),
                     //("Qingdao", 1506)
    ]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setSectionTextStyle()
        
        // cellstyle = default
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ChangeCityTableCitiesCell")
        // cellstyle = custom
        self.tableView.register(UINib.init(nibName: "StationsTableViewCell", bundle: nil), forCellReuseIdentifier: "StationsTableViewCell")
      
        searchTextField.delegate = self
        
    }
    
    // MARK: outlets
    
    @IBOutlet weak var searchTextField: UITextField!
    
    private var searchArray: SearchDataArray = [] {
        didSet {
            self.searchNull = (searchArray.count == 0)
            tableView.reloadData()
        }
    }
    
    private var searchNull = false// indicate the search result
    
    // MARK: UITextFieldDelegte
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchNull = true
        textField.resignFirstResponder()
        if let keyword = textField.text {
            AirRequest.sharedInstance.getSearchData(keyword: keyword) { (data, error) in
                DispatchQueue.main.async {
                    // handle errors
                    guard let data = data, error == nil else {
                        print(error ?? "getSearchData.error")
                        return
                    }
                    // decode Data to searchData
                    if let test = try? JSONDecoder().decode(SearchDataArray.self, from: data) {
                        self.searchArray = test
                    }
                }
               
            }
        }
        
        return true
    }
   
    // constants
    
    private struct Constants {
        static let searchSection = 0
        static let searchResultSection = 1 //dynamic, it is hide until search field return
        static let autoLocatedSection = 2
        static let hotCitiesSection = 3 //dynamic
        static let sectionCount = 4
        
        //static let rootViewController = "RootViewController" 字符串转class较麻烦
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return Constants.sectionCount
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == Constants.hotCitiesSection {
            return cityArray.count
        } else if section == Constants.searchResultSection {
            return searchArray.count
        }
        
        return 1
    }
    
    // show result for searching city
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == Constants.searchResultSection {
            let searchResult = String(format: "there is no result for your search (%@)".localized, searchTextField.text ?? "")
            return searchNull ? searchResult : nil
        }
        if section == Constants.hotCitiesSection {
            return "US Embassy and Consulates".localized
        }
        
        return super.tableView(tableView, titleForHeaderInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        // dynamic cells
        if indexPath.section == Constants.hotCitiesSection {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChangeCityTableCitiesCell", for: indexPath)
            cell.textLabel?.text = cityArray[indexPath.row].0
            return cell
        }
        
        if indexPath.section == Constants.searchResultSection {
            let cell: StationsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "StationsTableViewCell", for: indexPath) as! StationsTableViewCell
            cell.stationLabel.text = searchArray[indexPath.row].station
            cell.aqiLabel.text = searchArray[indexPath.row].aqi?.description
            cell.aqiLabel.backgroundColor = UIColor.lightGray
            if let aqi = searchArray[indexPath.row].aqi {
                AqiTable.setAqiLabelAsLegend(aqi: aqi, label: cell.aqiLabel)
            }
            return cell
        }
        
        // static cells
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    //reset row height because dynamic cells cause the height of cell changed
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == Constants.hotCitiesSection) || (indexPath.section == Constants.searchResultSection) {
            return self.tableView.rowHeight
        }
       
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    //当覆盖了静态的cell数据源方法时需要提供一个代理方法。
    //因为数据源对新加进来的cell一无所知，所以要使用这个代理方法
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        
        if (indexPath.section == Constants.hotCitiesSection) || (indexPath.section == Constants.searchResultSection)  {
            let newIndexPath = IndexPath(row: 0, section: indexPath.section)
            return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
        }
        
        return super.tableView(tableView, indentationLevelForRowAt: indexPath)
    }
    
    // navigation from table
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // cell = tableView.cellForRow(at: indexPath)
        // auto locate
        if indexPath.section == Constants.autoLocatedSection {
            // if locating function disabled, go to "change city" page
            if CLLocationManager.authorizationStatus() == .denied {
                // go to system setting page
                // check if location are enabled
                let alertController = UIAlertController(
                    title: "Enable location services?".localized,
                    message: "Your location is used to get air information in your city.".localized,
                    preferredStyle: .alert)
                let settingsAction = UIAlertAction(title: "Settings".localized, style: .default) { (_) -> Void in
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        })
                    }
                }
                let cancelAction = UIAlertAction(title: "Cancel".localized, style: .default, handler: nil)
                
                alertController.addAction(cancelAction)
                alertController.addAction(settingsAction)
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
                return
            }
            // auto located
            AirLocationManager.shareInstance.requestLocation {(location, error) in
                if let longitude = location?.coordinate.longitude,
                    let latitude = location?.coordinate.latitude {
                    AirRequest.sharedInstance.getAirDataWithGeo(latitude: latitude, longitude: longitude) { (data, error) in
                        DispatchQueue.main.async {
                            // handle errors
                            guard let data = data, error == nil else {
                                print(error ?? "requestLocation.error")
                                return
                            }
                            // decode Data to AirData
                            if let test = try? JSONDecoder().decode(AirData.self, from: data) {
                                airData = test
                                Settings.sharedInstance.stationID = airData?.idx ?? -1
                            }
                            
                            if let rootViewController = self.navigationController?.viewControllers[0] as? RootViewController {
                                rootViewController.refreshUI()
                            }
                            // go to main view
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                        
                    }
                }
            }
        }
        if indexPath.section == Constants.searchResultSection {
            Settings.sharedInstance.stationID = searchArray[indexPath.row].idx!
            // update main view UI
            if let rootViewController = self.navigationController?.viewControllers[0] as? RootViewController {
                rootViewController.refreshData()
            }
            // go to main view
            self.navigationController?.popToRootViewController(animated: true)
        }
        if indexPath.section == Constants.hotCitiesSection {
            Settings.sharedInstance.stationID = cityArray[indexPath.row].1
            // update main view UI
            if let rootViewController = self.navigationController?.viewControllers[0] as? RootViewController {
                rootViewController.refreshData()
            }
            // go to main view
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

}
