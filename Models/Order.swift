//
//  File.swift
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

    @Relationship(inverse: \OrderProduct.order)
    var orderProducts: [OrderProduct] = []
    
    let createTime: Date
    var addition: String
    var finished: Bool
    
    
    init(orderNumber: Int, createTime: Date, orderProducts: [OrderProduct], addition: String, finished: Bool) {
        self.id = UUID().uuidString
        self.createTime = createTime
        self.orderProducts = orderProducts
        self.addition = addition
        self.finished = finished
    }
    
}
