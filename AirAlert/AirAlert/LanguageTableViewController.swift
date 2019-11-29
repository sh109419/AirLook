//
//  LanguageTableViewController.swift
//  AirAlert
//
//  Created by hyf on 2018/12/18.
//  Copyright © 2018年 Deng Junqiang. All rights reserved.
//

import UIKit

class LanguageTableViewController: UITableViewController {
    
   
    @IBAction func DoneAction(_ sender: Any) {
        // 使用底部向上滑出的样式
       
        let language = 1 == Settings.sharedInstance.languageID ? "英文" : "Chinese, Simplified"
        
        // preferredStyle 为 ActionSheet
        let alertController = UIAlertController(title: nil, message: String(format: "Would you like to change the App language to %@?".localized, language), preferredStyle:.actionSheet)
        
        // 设置2个UIAlertAction
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: String(format: "Change to %@".localized, language), style: .default) { (UIAlertAction) in
            // save in UserDefault
            Settings.sharedInstance.languageID = self.selectedItem
            // set language
            Settings.sharedInstance.setAppLanguage()
            // Done to reintantiate the storyboards instantly
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            UIApplication.shared.keyWindow?.rootViewController = storyboard.instantiateInitialViewController()
        }
        
        // 添加到UIAlertController
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        // 弹出
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBOutlet weak var DoneBarButtonItem: UIBarButtonItem!
    
    // indecate which item is selected
    private var selectedItem = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedItem = Settings.sharedInstance.languageID
        // bar button item
        DoneBarButtonItem.isEnabled = false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return MultiLanguage.languageCount
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageTableViewCell", for: indexPath)
        
        cell.textLabel?.text = MultiLanguage.record[indexPath.row]
        
        cell.accessoryType = .none//UITableViewCellAccessoryNone
        if indexPath.row == selectedItem {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // only the selected section shows checkmark
        selectedItem = indexPath.row
        // refresh tableview
        tableView.reloadData()
        
        // set "Done" button status
        DoneBarButtonItem.isEnabled = (Settings.sharedInstance.languageID != selectedItem)
    }
    
}
