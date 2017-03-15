//
//  ChartFillFormatter.swift
//  coinb
//
//  Created by Hieu Nguyen on 3/15/17.
//  Copyright © 2017 FoodCompass. All rights reserved.
//

import Foundation
import Charts

class MyFillFormatter: IFillFormatter {
    func getFillLinePosition(dataSet: ILineChartDataSet, dataProvider: LineChartDataProvider) -> CGFloat {
        guard let yMin = dataProvider.lineData?.yMin, let yMax = dataProvider.lineData?.yMax else {
            return 0
        }
        
        let yRange = yMax - yMin
        let spaceBottomFactor = dataProvider.getAxis(YAxis.AxisDependency.right).spaceBottom
        let yBottom = yMin - (yRange * Double(spaceBottomFactor))
        
        return CGFloat(yBottom)
    }
}
