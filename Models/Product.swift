//
//  Product.swift
//  SimPOS
//
//  Created by Dong on 2024/1/31.
//

import Foundation
import SwiftData

@Model
class Product {
    @Attribute(.unique)
    let id: String
    
    @Attribute(.externalStorage)
    var imageData: Data?
    
    @Relationship(deleteRule: .cascade, inverse: \OrderProduct.product)
    var orderProducts: [OrderProduct] = []
    
    var name: String
    var price: Float
    var cost: Float?
    var storage: Int?
    
    
    init(imageData: Data? , name: String, price: Float, cost: Float?, storage: Int?) {
        self.id = UUID().uuidString
        self.imageData = imageData
        self.name = name
        self.price = price
        self.cost = cost
        self.storage = storage
    }
}
