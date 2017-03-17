//
//  CoindeskClient.swift
//  coinb
//
//  Created by Hieu Nguyen on 3/14/17.
//  Copyright © 2017 FoodCompass. All rights reserved.
//

import Foundation
import Alamofire

enum CoindeskRouter: URLRequestConvertible
{
    static let ENDPOINT_URL = "https://api.coindesk.com/v1/bpi/historical/close.json"
    
    case Week(String)
    case Month(String)
    case Year(String)
    case All(String)
    
    var beginningDate: Date {
        let calendar = Calendar.current
        let now = Date()
        switch self {
        case .Week:
            let oneWeekAgoDate = calendar.date(byAdding: Calendar.Component.weekOfYear, value: -1, to: now)
            return (oneWeekAgoDate != nil) ? oneWeekAgoDate!: now
        case .Month:
            let oneMonthAgoDate = calendar.date(byAdding: Calendar.Component.month, value: -1, to: now)
            return (oneMonthAgoDate != nil) ? oneMonthAgoDate!: now
        case .Year:
            let oneYearAgoDate = calendar.date(byAdding: Calendar.Component.year, value: -1, to: now)
            return (oneYearAgoDate != nil) ? oneYearAgoDate!: now
        case .All:
            let beginningAllDate = Constants.dateFormatter.date(from: "2010-07-18")
            return (beginningAllDate != nil) ? beginningAllDate!: now
        }
    }
    
    var endDate: Date {
        return Date()
    }
    
    var type: String {
        switch self
        {
        case .Week:
            return "week"
        case .Month:
            return "month"
        case .Year:
            return "year"
        case .All:
            return "all"
        }
    }
    
    var currency: String {
        switch self
        {
        case .Week (let currency):
            return currency
        case .Month (let currency):
            return currency
        case .Year (let currency):
            return currency
        case .All (let currency):
            return currency
        }
    }

    public func asURLRequest() throws -> URLRequest {
        let parameters: [String: Any] = {
            switch self
            {
            case .Week (let currency):
                return ["currency": currency, "start": Constants.dateFormatter.string(from: self.beginningDate), "end": Constants.dateFormatter.string(from: self.endDate)]
            case .Month (let currency):
                return ["currency": currency, "start": Constants.dateFormatter.string(from: self.beginningDate), "end": Constants.dateFormatter.string(from: self.endDate)]
            case .Year (let currency):
                return ["currency": currency, "start": Constants.dateFormatter.string(from: self.beginningDate), "end": Constants.dateFormatter.string(from: self.endDate)]
            case .All (let currency):
                return ["currency": currency, "start": Constants.dateFormatter.string(from: self.beginningDate), "end": Constants.dateFormatter.string(from: self.endDate)]
            }
        }()
        
        let url = try CoindeskRouter.ENDPOINT_URL.asURL()
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.timeoutInterval = TimeInterval(10 * 1000)
        
        //debugPrint("[PARAMS] \(parameters)")
        
        return try URLEncoding.default.encode(request, with: parameters)
    }
    
}
