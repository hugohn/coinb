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
    private var pendingRequests = [String: Bool]()
    
    private init() {
    }
    
    func setupCoinbaseAccessToken(oAuthAccessToken accessToken: String!) {
        client = Coinbase(oAuthAccessToken: accessToken)
        debugPrint("initialized Coinbase with token \(accessToken)")
    }
    
    func loadSpotPrice(withCurrency currency: String!) {
        debugPrint("[API] hitting Coinbase API")
        client.getSpotRate(withCurrency: currency) { (balance: CoinbaseBalance?, error: Error?) in
            guard error == nil else {
                debugPrint("[API] error = \(error.debugDescription)")
                return
            }
            
            if let balance = balance {
                NotificationCenter.default.post(name:Notification.Name(rawValue: Constants.kNewSpotData),
                                                object: nil,
                                                userInfo: ["price": balance.amount])
            }
        }
    }
    
    func loadHistoricalPrice(withRouter router: CoindeskRouter) {
        let hasCache = checkPriceQueryCache(router: router)
        
        if !hasCache {
            NotificationCenter.default.post(name:Notification.Name(rawValue: Constants.kLoadingHomeData),
                                            object: nil,
                                            userInfo: nil)
        }
        
        guard pendingRequests[router.type] == nil else { return }
        pendingRequests[router.type] = true
        
        // fire API request
        let queue = hasCache ? Queues.backgroundQueue: Queues.userInitiatedQueue
        debugPrint("[API] hitting API, router type = \(router.type); backgroundQueue = \(hasCache)")
        Alamofire
            .request(router)
            .validate()
            .responseJSON(queue: queue) { (response: DataResponse<Any>) in
                guard response.result.isSuccess else {
                    print("[API] Error while fetching historical price data: \(response.result.error)")
                    self.pendingRequests.removeValue(forKey: router.type)
                    return
                }
                
                guard let dictionary = response.result.value as? [String: Any],
                      let bpi = dictionary["bpi"] as? [String: Double] else {
                        print("[API] Invalid data received from Coindesk API")
                        self.pendingRequests.removeValue(forKey: router.type)
                        return
                }
                
                self.processPriceData(router: router, bpi: bpi)
                self.updatePriceQueryCache(router: router, bpi: bpi)
                self.pendingRequests.removeValue(forKey: router.type)
        }
    }
    
    func checkPriceQueryCache(router: CoindeskRouter) -> Bool {
        guard PriceQueryCache.getPriceCache(type: router.type) != nil else { return false }
        
        // has cache data, notify home so UI can be immediately updated
        NotificationCenter.default.post(name:Notification.Name(rawValue: Constants.kNewHomeData),
                                        object: nil,
                                        userInfo: ["type": router.type, "pricePoints": PricePoint.getPricePoints(beginningDate: router.beginningDate, endDate: router.endDate)])
        
        return true
    }
    
    func processPriceData(router: CoindeskRouter, bpi: [String: Double]) {
        var hasNewPricePoint = false
        let existingCacheForRouter = PriceQueryCache.getPriceCache(type: router.type)
        for (date, price) in bpi {
            //debugPrint("[RAW] date = \(date); price = \(price)")
            if PricePoint.addPricePoint(currency: router.currency, date: date, price: price) != nil {
                hasNewPricePoint = true
            }
        }
        
        if existingCacheForRouter == nil || hasNewPricePoint {
            NotificationCenter.default.post(name:Notification.Name(rawValue: Constants.kNewHomeData),
                                            object: nil,
                                            userInfo: ["type": router.type, "pricePoints": PricePoint.getPricePoints(beginningDate: router.beginningDate, endDate: router.endDate)])
        }
    }
    
    func updatePriceQueryCache(router: CoindeskRouter, bpi: [String: Double]) {
        do {
            let jsonData: Data = try JSONSerialization.data(withJSONObject: bpi, options: [])
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
            let query = router.urlRequest?.url?.absoluteString ?? "N/A"
            
            var updateCache = true
            if let existingCacheForRouter = PriceQueryCache.getPriceCache(type: router.type) {
                if existingCacheForRouter.json == jsonString {
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
