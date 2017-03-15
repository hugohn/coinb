//
//  MyXAxisYearFormatter.swift
//  coinb
//
//  Created by Hieu Nguyen on 3/15/17.
//  Copyright © 2017 FoodCompass. All rights reserved.
//

import Foundation
import Charts

class MyXAxisYearFormatter: NSObject, IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value)
        return Constants.yearFormatter.string(from: date)
    }
}
