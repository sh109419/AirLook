//
//  AirQualityLevelsTableViewController.swift
//  AirAlert
//
//  Created by hyf on 2018/9/24.
//  Copyright © 2018年 Deng Junqiang. All rights reserved.
//

import UIKit

class AirQualityLevelsTableViewController: UITableViewController {
   
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return AqiTable.recordCount
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return AqiTable.rowCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AirQualityLevelsTableViewCell", for: indexPath)
        
        if indexPath.row == 0 {
            cell.textLabel?.text = AqiTable.RowTitle.aqi.localized
            cell.detailTextLabel?.text = AqiTable.record[indexPath.section].aqi
        }
        if indexPath.row == 1 {
            cell.textLabel?.text = AqiTable.RowTitle.apl.localized
            cell.detailTextLabel?.text = AqiTable.record[indexPath.section].apl.localized
        }
        if indexPath.row == 2 {
            cell.textLabel?.text = AqiTable.RowTitle.desc.localized
            cell.detailTextLabel?.text = AqiTable.record[indexPath.section].desc.localized
        }
        
        // show color
        AqiTable.setAqiCellAsLegend(level: indexPath.section, cell: cell)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " " // show header as separator line
    }


}
