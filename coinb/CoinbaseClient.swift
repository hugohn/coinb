//
//  CoinbaseClient.swift
//  coinb
//
//  Created by Hieu Nguyen on 3/12/17.
//  Copyright © 2017 FoodCompass. All rights reserved.
//

import Foundation
import coinbase_official

class CoinbaseClient {
    static let sharedInstance = CoinbaseClient()
    private var client: Coinbase = Coinbase()
    
    private init() {
    }
    
    func setupWithAccessToken(oAuthAccessToken accessToken: String!) {
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
    
}
