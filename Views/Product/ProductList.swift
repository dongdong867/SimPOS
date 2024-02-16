//
//  ProductList.swift
//  
//
//  Created by Dong on 2024/2/13.
//

import SwiftData
import SwiftUI

final class ProductList: ObservableObject {
    @Published var products = [Product]()
    
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchProducts(with: "")
    }
    
    func fetchProducts(with query: String) {
        let descriptor = FetchDescriptor<Product> (predicate: #Predicate {
            if(query.isEmpty) { true }
            else {
                $0.name.localizedStandardContains(query)
            }
        }, sortBy: [.init(\.name), .init(\.code)])

        products = (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func createProduct(_ product: Product) {
        modelContext.insert(product)
    }
    
    func deleteProduct(_ product: Product) {
        modelContext.delete(product)
    }
}
