//
//  ProductScanner.swift
//
//
//  Created by Dong on 2024/2/12.
//

import Foundation
import SwiftData

final class ProductScanner: ObservableObject {
    @Published var barCode = ""
    @Published var error: ProductScannerError?
    @Published var product: Product?
    
    var modelContext: ModelContext
    var descriptor: FetchDescriptor<Product> {
        FetchDescriptor<Product>(predicate: #Predicate { $0.code == barCode })
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func searchBarcode() -> Bool {
        if let count = try? modelContext.fetchCount(descriptor),
           count > 0 {
            return true
        }
        return false
    }
    
    func fetchProduct() -> Bool {
        guard let product = try? modelContext.fetch(descriptor).first
        else { return false }
        
        self.product = product
        return true
    }
    
    enum ProductScannerError: Error, LocalizedError {
        case internalError(ScannerController.ScannerError)
        case notFound(String), fetchError
        
        func description() -> String {
            switch self {
                case .internalError(let error):
                    error.description()
                case .notFound(let barcode):
                    "Product not found with bar code \(barcode)"
                case .fetchError:
                    "Error on fetching from database."
            }
        }
    }
}
