//
//  ProductCard.swift
//  SimPOS
//
//  Created by Dong on 2024/2/1.
//

import SwiftData
import SwiftUI

struct ProductCard: View {
    let product: Product
    
    var body: some View {
        VStack {
            ProductImage(data: product.imageData)
            Text(product.name)
        }
    }
}
