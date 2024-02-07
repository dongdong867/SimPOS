//
//  Order.swift
//  SimPOS
//
//  Created by Dong on 2024/1/31.
//

import Foundation
import SwiftData

@Model
final class Order {
    @Attribute(.unique)
    let id: String

    @Relationship(deleteRule: .cascade, inverse: \OrderProduct.order)
    var orderProducts: [OrderProduct] = []
    
    let createTime: Date
    let orderNumber: Int
    var note: String
    var finished: Bool
    
    
    init(orderNumber: Int, createTime: Date, orderProducts: [OrderProduct], note: String, finished: Bool) {
        self.id = UUID().uuidString
        self.orderNumber = orderNumber
        self.createTime = createTime
        self.orderProducts = orderProducts
        self.note = note
        self.finished = finished
    }
    
}
