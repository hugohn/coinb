//
//  Queues.swift
//  coinb
//
//  Created by Hieu Nguyen on 3/16/17.
//  Copyright © 2017 FoodCompass. All rights reserved.
//

import Foundation

struct Queues {
    static let backgroundQueue = DispatchQueue.global(qos: .background)
    static let utilityQueue = DispatchQueue.global(qos: .utility)
    static let userInitiatedQueue = DispatchQueue.global(qos: .userInitiated)
}
