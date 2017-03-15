
//  PriceQueryCache
//  coinb
//
//  Created by Hieu Nguyen on 3/15/17.
//  Copyright © 2017 FoodCompass. All rights reserved.
//

import Foundation
import RealmSwift

class PriceQueryCache: Object {
    dynamic var type = ""
    dynamic var query = ""
    dynamic var json = ""
    dynamic var lastModified = Date()
    
    override static func indexedProperties() -> [String] {
        return ["type", "query", "lastModified"]
    }
    
    override class func primaryKey() -> String? {
        return "type"
    }
    
    func save(update: Bool) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(self, update: update)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    class func addPriceCache(type: String!, query: String!, json: String!) {
        let priceQueryCache = PriceQueryCache()
        priceQueryCache.type = type
        priceQueryCache.query = query
        priceQueryCache.json = json
        priceQueryCache.lastModified = Date()
        priceQueryCache.save(update: true)
    }
    
    class func getPriceCache(type: String!) -> PriceQueryCache? {
        do {
            let realm = try Realm()
            return realm.object(ofType: PriceQueryCache.self, forPrimaryKey: type)
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
}
