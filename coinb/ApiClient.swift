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
                completion("\(balance.amount!) \(balance.currency!)")
            }
        }
    }
    
    func getHistoricalPrice(withRouter router: CoindeskRouter) {
        guard checkPriceQueryCache(router: router) == false else { return }
        
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
    
    func checkPriceQueryCache(router: CoindeskRouter) -> Bool {
        guard let priceQueryCache = PriceQueryCache.getPriceCache(type: router.type) else { return false }

//        NotificationCenter.default.post(name:Notification.Name(rawValue: kNewHomeData),
//                                        object: nil,
//                                        userInfo: ["beginningDate": router.beginningDate, "endDate": router.endDate])

        // has cache data, notify home so UI can be immediately updated
        debugPrint("[CACHE] json = \(priceQueryCache.json)")
        if let data = priceQueryCache.json.data(using: .utf8) {
            do {
                if let bpi = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Double] {
                    processPriceData(router: router, bpi: bpi)
                    debugPrint("[CACHE] loaded.")
                }
            } catch {
                debugPrint(error.localizedDescription)
            }
        }

        return true
    }
    
    func processPriceData(router: CoindeskRouter, bpi: [String: Double]) {
        for (date, price) in bpi {
            debugPrint("[RAW] date = \(date); price = \(price)")
            PricePoint.addPricePoint(currency: router.currency, date: date, price: price)
        }
        
        NotificationCenter.default.post(name:Notification.Name(rawValue: kNewHomeData),
                                        object: nil,
                                        userInfo: ["beginningDate": router.beginningDate, "endDate": router.endDate])
    }
    
    func updatePriceQueryCache(router: CoindeskRouter, bpi: [String: Double]) {
        do {
            let jsonData: Data = try JSONSerialization.data(withJSONObject: bpi, options: [])
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
            let query = router.urlRequest?.url?.absoluteString ?? "N/A"
            PriceQueryCache.addPriceCache(type: router.type, query: query, json: jsonString)
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
        }
    }
    
    
}
