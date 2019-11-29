//
//  AlertLevelTableViewController.swift
//  AirAlert
//
//  Created by hyf on 2018/9/12.
//  Copyright © 2018年 Deng Junqiang. All rights reserved.
//

import UIKit

class AlertLevelTableViewController: UITableViewController {

    // indecate which item is selected
    private var selectedItem = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // get selected section from setting data
        selectedItem = Settings.sharedInstance.alertLevel
        //tableView.estimatedSectionHeaderHeight = tableView.sectionHeaderHeight
        //tableView.sectionHeaderHeight = UITableViewAutomaticDimension
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return AqiTable.recordCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlertLevelTableViewCell", for: indexPath)
      
        cell.textLabel?.text = AqiTable.record[indexPath.row].aqi
        cell.detailTextLabel?.text = AqiTable.record[indexPath.row].apl.localized
    
        cell.accessoryType = .none//UITableViewCellAccessoryNone
        if indexPath.row == selectedItem {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // only the selected section shows checkmark
        selectedItem = indexPath.row
        if Settings.sharedInstance.alertLevel != selectedItem {
            Settings.sharedInstance.alertLevel = selectedItem
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UITableViewHeaderFooterView()
        header.textLabel?.text = AqiTable.RowTitle.aqi.localized
        header.detailTextLabel?.text = AqiTable.RowTitle.apl.localized// only for group style
        return header
    }
  /*
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return  "\(AqiTable.RowTitle.aqi) \n \(AqiTable.RowTitle.apl) "  // show header as separator line
    }
   */
   override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    
    //tableView.estimatedRowHeight = tableView.rowHeight
    //tableView.rowHeight = UITableViewAutomaticDimension
    return 44 * 2
    }
    
   
}
