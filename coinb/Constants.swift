//
//  Constants.swift
//  coinb
//
//  Created by Hieu Nguyen on 3/15/17.
//  Copyright © 2017 FoodCompass. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    static let kNewSpotData = "kNewSpotData"
    static let kNewHomeData = "kNewHomeData"
    static let kLoadingHomeData = "kLoadingHomeData"
    
    static var currencyFormatter: NumberFormatter {
        struct Static {
            static let instance: NumberFormatter = NumberFormatter()
        }
        Static.instance.numberStyle = .currency
        Static.instance.locale = NSLocale.current
        
        return Static.instance
    }
    
    static var roundedCurrencyFormatter: NumberFormatter {
        struct Static {
            static let instance: NumberFormatter = NumberFormatter()
        }
        Static.instance.numberStyle = .currency
        Static.instance.locale = NSLocale.current
        Static.instance.maximumFractionDigits = 0
        
        return Static.instance
    }
    
    static var dateFormatter: DateFormatter {
        struct Static {
            static let instance: DateFormatter = DateFormatter()
        }
        Static.instance.dateFormat = "yyyy-MM-dd"
        
        return Static.instance
    }
    
    static var shortDateFormatter: DateFormatter {
        struct Static {
            static let instance: DateFormatter = DateFormatter()
        }
        Static.instance.dateFormat = "MM/dd"
        
        return Static.instance
    }
    
    static var monthFormatter: DateFormatter {
        struct Static {
            static let instance: DateFormatter = DateFormatter()
        }
        Static.instance.dateFormat = "MMM"
        
        return Static.instance
    }
    
    static var yearFormatter: DateFormatter {
        struct Static {
            static let instance: DateFormatter = DateFormatter()
        }
        Static.instance.dateFormat = "MM/yyyy"
        
        return Static.instance
    }
    
    static let primaryColor = UIColor(red: 1/255, green: 90/255, blue: 158/255, alpha: 1)
    static let secondaryColor = UIColor(red: 31/255, green: 122/255, blue: 200/255, alpha: 1)
    
    static let grayColor = UIColor(red: 76/255, green: 109/255, blue: 157/255, alpha: 1)
    static let blackColor = UIColor(red: 23/255, green: 23/255, blue: 23/255, alpha: 1)
    
    static func getSymbolForCurrencyCode(code: String) -> String? {
        let locale = NSLocale(localeIdentifier: code)
        return locale.displayName(forKey: NSLocale.Key.currencySymbol, value: code)
    }
}
