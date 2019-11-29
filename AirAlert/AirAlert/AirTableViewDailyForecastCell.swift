//
//  AirTableViewDailyForecastCell.swift
//  AirAlert
//
//  Created by hyf on 2018/11/27.
//  Copyright © 2018年 Deng Junqiang. All rights reserved.
//

import UIKit
/*
 define this cell to show daily forecast dynamic in Static table
 */

class AirTableViewDailyForecastCell: UITableViewCell {

    @IBOutlet weak var aqiImage: UIImageView!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var aqiRangeLabel: UILabel!
}
