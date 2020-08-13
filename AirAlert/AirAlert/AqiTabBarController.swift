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
        
        // register swipe gesture 滑动换页
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        leftSwipeGesture.direction = UISwipeGestureRecognizer.Direction.left
        view.addGestureRecognizer(leftSwipeGesture)
        
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        rightSwipeGesture.direction = UISwipeGestureRecognizer.Direction.right
        view.addGestureRecognizer(rightSwipeGesture)
        
    }


    // MARK: - tap gesture function
    // Swipe left/right between tabs with an animation
    // 利用手势实现tabbarController滑动切换页面
    
    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer) {
        // get selected index
        let selectedIndex = self.selectedIndex
        // Get the views.
        //let fromView: UIView = self.selectedViewController!.view
        
        if (sender.direction == UISwipeGestureRecognizer.Direction.left) {
            
            let tabCount = self.viewControllers!.count
            
            if (selectedIndex < tabCount - 1) {
                // 初始化动画的持续时间，类型和子类型
                let transition = CATransition()
                transition.duration = 0.3
                transition.type = CATransitionType.reveal
                transition.subtype = CATransitionSubtype.fromRight
                
                let toView  : UIView = self.viewControllers![selectedIndex+1].view
                self.view.addSubview(toView)
                // 执行刚才添加好的动画
                self.view.layer.add(transition, forKey: nil)
                toView.removeFromSuperview()
                self.selectedIndex += 1
                self.title = tabArray[self.selectedIndex]
            }
            
        }
        
        if (sender.direction == UISwipeGestureRecognizer.Direction.right) {
            
            if (selectedIndex > 0) {
                // 初始化动画的持续时间，类型和子类型
                let transition = CATransition()
                transition.duration = 0.3
                transition.type = CATransitionType.reveal
                transition.subtype = CATransitionSubtype.fromLeft
                
                let toView  : UIView = self.viewControllers![selectedIndex-1].view
                self.view.addSubview(toView)
                // 执行刚才添加好的动画
                self.view.layer.add(transition, forKey: nil)
                toView.removeFromSuperview()
                self.selectedIndex -= 1
                self.title = tabArray[self.selectedIndex]
            }
            if (selectedIndex == 0) {
                self.navigationController?.popToRootViewController(animated: true)
            }
        
        }
        
    }
}
