//
//  SettingTableViewController.swift
//  AirAlert
//
//  Created by hyf on 2018/9/7.
//  Copyright © 2018年 Deng Junqiang. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {

    @IBOutlet weak var cityNameLabel: UILabel!
    
    @IBOutlet weak var alertLevelLabel: UILabel!
    @IBOutlet weak var recoveryEnabledSwitch: UISwitch!
    
    @IBAction func recoveryEnabledSwitchChanged(_ sender: UISwitch) {
        Settings.sharedInstance.recoveryEnabled = sender.isOn
    }

    @IBOutlet weak var versionLabel: UILabel!
    
    @IBOutlet weak var languageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSectionTextStyle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        alertLevelLabel.text = AqiTable.record[Settings.sharedInstance.alertLevel].apl.localized
        recoveryEnabledSwitch.isOn = Settings.sharedInstance.recoveryEnabled
        cityNameLabel.text = airData?.city?.localizedName()
        languageLabel.text = MultiLanguage.getLanguageText(id: Settings.sharedInstance.languageID)
        //version no
        let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        versionLabel.text = currentVersion
    }
    
    // MARK: - Table view data source

    let sectionCount = 5
    let rowCount = [1, 2, 2, 1, 2]
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionCount
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return rowCount[section]
    }
    

}
