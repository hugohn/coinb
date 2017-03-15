//
//  CoinbaseClient.swift
//  coinb
//
//  Created by Hieu Nguyen on 3/12/17.
//  Copyright © 2017 FoodCompass. All rights reserved.
//

import Foundation
import coinbase_official
import Alamofire

class ApiClient {
    static let sharedInstance = ApiClient()
    private var client: Coinbase = Coinbase()
    
    private init() {
    }
    
    func setupCoinbaseAccessToken(oAuthAccessToken accessToken: String!) {
        client = Coinbase(oAuthAccessToken: accessToken)
        debugPrint("initialized Coinbase with token \(accessToken)")
    }
    
    func getSpotPrice(withCurrency currency: String!, completion: ((String?) -> ())!) {
        client.getSpotRate(withCurrency: currency) { (balance: CoinbaseBalance?, error: Error?) in
            guard error == nil else {
                debugPrint("error = \(error.debugDescription)")
                completion(nil)
                return
            }
            
            if let balance = balance {
                debugPrint("1 BTC = \(balance.amount!) \(balance.currency!)")
                completion(balance.amount)
            }
        }
    }
    
    func getHistoricalPrice(withRouter router: CoindeskRouter) {
        checkPriceQueryCache(router: router)
        
        // fire API request
        debugPrint("hitting API")
        Alamofire
            .request(router)
            .validate()
            .responseJSON { (response: DataResponse<Any>) in
                guard response.result.isSuccess else {
                    print("Error while fetching historical price data: \(response.result.error)")
                    return
                }
                
                guard let dictionary = response.result.value as? [String: Any],
                      let bpi = dictionary["bpi"] as? [String: Double] else {
                        print("Invalid data received from Coindesk API")
                        return
                }
                
                self.processPriceData(router: router, bpi: bpi)
                self.updatePriceQueryCache(router: router, bpi: bpi)
        }
    }
    
    func checkPriceQueryCache(router: CoindeskRouter) {
        if PriceQueryCache.getPriceCache(type: router.type) != nil {
            // has cache data, notify home so UI can be immediately updated
            NotificationCenter.default.post(name:Notification.Name(rawValue: Constants.kNewHomeData),
                                            object: nil,
                                            userInfo: ["beginningDate": router.beginningDate, "endDate": router.endDate])
            
        }
    }
    
    func processPriceData(router: CoindeskRouter, bpi: [String: Double]) {
        var hasNewData = false
        for (date, price) in bpi {
            debugPrint("[RAW] date = \(date); price = \(price)")
            if PricePoint.addPricePoint(currency: router.currency, date: date, price: price) != nil {
                hasNewData = true
            }
        }
        
        if hasNewData {
            debugPrint("[RAW] hasNewData")
            NotificationCenter.default.post(name:Notification.Name(rawValue: Constants.kNewHomeData),
                                            object: nil,
                                            userInfo: ["beginningDate": router.beginningDate, "endDate": router.endDate])
        }
    }
    
    func updatePriceQueryCache(router: CoindeskRouter, bpi: [String: Double]) {
        do {
            let jsonData: Data = try JSONSerialization.data(withJSONObject: bpi, options: [])
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
            let query = router.urlRequest?.url?.absoluteString ?? "N/A"
            
            var updateCache = true
            if let existingCache = PriceQueryCache.getPriceCache(type: router.type) {
                if existingCache.json == jsonString {
                    updateCache = false
                }
            }
            
            if updateCache {
                PriceQueryCache.addPriceCache(type: router.type, query: query, json: jsonString)
                debugPrint("[CACHE] updated cache")
            }
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
        }
    }
    
    
}
