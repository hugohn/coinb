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
    dynamic var key = ""
    dynamic var currency = ""
    dynamic var date = Date()
    dynamic var price: Double = 0.0
    
    override static func indexedProperties() -> [String] {
        return ["key", "currency", "date"]
    }
    
    override class func primaryKey() -> String? {
        return "key"
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
    
    class func addPricePoint(currency: String!, date: String!, price: Double) {
        let key = currency + date
        do {
            let realm = try Realm()
            if realm.object(ofType: PricePoint.self, forPrimaryKey: key) != nil {
                //debugPrint("Price point already exists")
                return
            }
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
            return
        }
        
        let pricePoint = PricePoint()
        pricePoint.key = key
        pricePoint.currency = currency
        pricePoint.date = CoindeskRouter.dateFormatter.date(from: date)!
        pricePoint.price = price
        pricePoint.save()
    }
    
    class func getPricePoints(beginningDate: Date!, endDate: Date!) -> Results<PricePoint> {
        do {
            let realm = try Realm()
            return realm.objects(PricePoint.self).filter("date BETWEEN {%@, %@}", beginningDate, endDate).sorted(byProperty: "date", ascending: true)
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
}
