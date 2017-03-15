//
//  PricePoint.swift
//  coinb
//
//  Created by Hugo Nguyen on 3/14/17.
//  Copyright © 2017 FoodCompass. All rights reserved.
//

import Foundation
import RealmSwift

class PricePoint: Object {
    dynamic var id = ""
    dynamic var query = ""
    dynamic var currency = ""
    dynamic var date = ""
    dynamic var price: Double = 0.0
    
    override static func indexedProperties() -> [String] {
        return ["id", "query", "currency", "date"]
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    func save() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(self)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    class func addPricePoint(query: String!, currency: String!, date: String!, price: Double) {
        let id = query + date
        do {
            let realm = try Realm()
            if let price = realm.object(ofType: PricePoint.self, forPrimaryKey: id) {
//                debugPrint("Price point already exists")
                return
            }
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
            return
        }
        
        let pricePoint = PricePoint()
        pricePoint.id = id
        pricePoint.query = query
        pricePoint.currency = currency
        pricePoint.date = date
        pricePoint.price = price
        pricePoint.save()
    }
    
    class func getPricePoints(query: String) -> Results<PricePoint> {
        do {
            let realm = try Realm()
            return realm.objects(PricePoint.self).filter("query == %@", query).sorted(byProperty: "date", ascending: true)
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
}
