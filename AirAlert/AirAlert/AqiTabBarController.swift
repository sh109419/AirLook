//
//  AqiTabBarController.swift
//  AirAlert
//
//  Created by hyf on 2019/3/26.
//  Copyright © 2019年 Deng Junqiang. All rights reserved.
//

import UIKit

class AqiTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    
    let tabArray = ["PM Quantity".localized,
                    "PM Weight".localized,
                    "AQI Forcast".localized,
                    //discard
                    "Individual AQI".localized,
                     "Nearest Cities".localized,
                     "City Map".localized]
   
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        tabBarController.title = tabArray[tabBarController.selectedIndex]
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        delegate = self
        self.title = tabArray[0]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
