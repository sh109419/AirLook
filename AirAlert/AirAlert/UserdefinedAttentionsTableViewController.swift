//
//  UserdefinedAttationsTableViewController.swift
//  AirAlert
//
//  Created by hyf on 2019/2/24.
//  Copyright © 2019年 Deng Junqiang. All rights reserved.
//

import UIKit

class UserdefinedAttentionsTableViewController: UITableViewController {
    
    private var attentions:  [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // prepare data
        attentions = UserDefaults.standard.stringArray(forKey: AttentionConstants.userdefinedAttentions)
    }
    
    @IBAction func SaveAction(_ sender: Any) {
        
        // save to UserDefaults
        if let rows = self.tableView.indexPathsForVisibleRows  {// make sure all rows are visible
            var attentions = [String]()
            for row in rows {
                let cell = self.tableView.cellForRow(at: row)
                let text = (cell?.contentView.subviews.first as! UITextView).text
                //print (text)
                attentions.append(text ?? "")
            }
            UserDefaults.standard.set(attentions, forKey: AttentionConstants.userdefinedAttentions)
        }
        
        // back to Settings
        self.navigationController?.popViewController(animated: true)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return AqiTable.recordCount
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserdefinedAttentionsTableViewCell", for: indexPath)

        
        (cell.contentView.subviews.first as! UITextView).text = attentions?[indexPath.section] ?? AttentionConstants.defaultAttentions[indexPath.section]
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = AqiTable.record[section].aqi + " " + AqiTable.record[section].apl.localized
        return title
    }
    

    
  

   

    
}
