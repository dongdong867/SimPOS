//
//  OrderProduct.swift
//  SimPOS
//
//  Created by Dong on 2024/1/31.
//

import Foundation
import SwiftData

@Model
class OrderProduct {
    var product: Product
    var order: Order
    var amount: Int
    
    
    init(product: Product, order: Order, amount: Int) {
        self.product = product
        self.order = order
        self.amount = amount
    }
}
