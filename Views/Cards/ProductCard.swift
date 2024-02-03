//
//  ProductCard.swift
//  
//
//  Created by Dong on 2024/2/1.
//

import SwiftData
import SwiftUI

struct ProductCard: View {
    let product: Product
    
    var body: some View {
        VStack {
            if let imageData = product.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .scaledToFit()
            }
            
            Text(product.name)
        }
    }
}

#Preview {
    ProductCard(product: Product(imageData: nil, name: "test", price: 100, cost: 100, storage: 100))
        .modelContainer(for: [Product.self])
}
