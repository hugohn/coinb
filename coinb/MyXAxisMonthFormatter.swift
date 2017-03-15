//
//  MyXAxisMonthFormatter.swift
//  coinb
//
//  Created by Hieu Nguyen on 3/15/17.
//  Copyright © 2017 FoodCompass. All rights reserved.
//

import Foundation
import Charts

class MyXAxisMonthFormatter: NSObject, IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value)
        return Constants.monthFormatter.string(from: date)
    }
}
