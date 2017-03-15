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
    
    func getSpotPrice(withCurrency: String!, completion: ((String?) -> ())!) {
        client.getSpotRate(withCurrency: withCurrency) { (balance: CoinbaseBalance?, error: Error?) in
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
    
    func getHistoricalPrice(withCurrency: String!, completion: ((Bool) -> ())!) {
        let urlConvertible = CoindeskRouter.Year(withCurrency)
        let urlString = urlConvertible.urlRequest?.url?.absoluteString ?? "NA"
        
        Alamofire
            .request(urlConvertible)
            .validate()
            .responseJSON { (response: DataResponse<Any>) in
                guard response.result.isSuccess else {
                    print("Error while fetching historical price data: \(response.result.error)")
                    completion(false)
                    return
                }
                
                guard let value = response.result.value as? [String: Any],
                      let bpi = value["bpi"] as? [String: Double] else {
                        print("Invalid data received from Coindesk API")
                        completion(false)
                        return
                }
                
                for (date, price) in bpi {
                    debugPrint("date = \(date); price = \(price)")
                    PricePoint.addPricePoint(query: urlString, currency: withCurrency, date: date, price: price)
                }
                
                completion(true)
        }
    }
}
