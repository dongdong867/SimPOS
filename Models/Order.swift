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
    var subtotal: Float
    var note: String
    var finished: Bool
    
    
    init(createTime: Date, orderNumber: Int, subtotal: Float, note: String, finished: Bool) {
        self.id = UUID().uuidString
        self.orderProducts = []
        self.createTime = createTime
        self.orderNumber = orderNumber
        self.subtotal = subtotal
        self.note = note
        self.finished = finished
    }
    
}
