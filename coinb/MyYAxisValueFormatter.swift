//
//  MyYAxisValueFormatter.swift
//  coinb
//
//  Created by Hieu Nguyen on 3/15/17.
//  Copyright © 2017 FoodCompass. All rights reserved.
//

import Foundation
import Charts

class MyYAxisValueFormatter: NSObject, IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let priceNumber = NSNumber(value: value)
        return Constants.roundedCurrencyFormatter.string(from: priceNumber)!
    }
}
