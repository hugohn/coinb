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
    
    static var dateFormatter: DateFormatter {
        struct Static {
            static let instance: DateFormatter = DateFormatter()
        }
        Static.instance.dateFormat = "yyyy-MM-dd"
        
        return Static.instance
    }
    
    case Week(String)
    case Month(String)
    case Year(String)
    case All(String)
    
    public func asURLRequest() throws -> URLRequest {
        let parameters: [String: Any] = {
            let calendar = Calendar.current
            let now = Date()
            switch self
            {
            case .Week (let currency):
                let oneWeekAgoDate = calendar.date(byAdding: Calendar.Component.weekOfYear, value: -1, to: now)
                return ["currency": currency, "start": CoindeskRouter.dateFormatter.string(from: oneWeekAgoDate!), "end": CoindeskRouter.dateFormatter.string(from: now)]
            case .Month (let currency):
                let oneMonthAgoDate = calendar.date(byAdding: Calendar.Component.month, value: -1, to: now)
                return ["currency": currency, "start": CoindeskRouter.dateFormatter.string(from: oneMonthAgoDate!), "end": CoindeskRouter.dateFormatter.string(from: now)]
            case .Year (let currency):
                let oneYearAgoDate = calendar.date(byAdding: Calendar.Component.year, value: -1, to: now)
                return ["currency": currency, "start": CoindeskRouter.dateFormatter.string(from: oneYearAgoDate!), "end": CoindeskRouter.dateFormatter.string(from: now)]
            case .All (let currency):
                let beginningDate = CoindeskRouter.dateFormatter.date(from: "2010-07-18")
                return ["currency": currency, "start": CoindeskRouter.dateFormatter.string(from: beginningDate!), "end": CoindeskRouter.dateFormatter.string(from: now)]
            }
        }()
        
        let url = try CoindeskRouter.ENDPOINT_URL.asURL()
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.timeoutInterval = TimeInterval(10 * 1000)
        
        return try URLEncoding.default.encode(request, with: parameters)
    }
    
}
