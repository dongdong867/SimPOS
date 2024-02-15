//
//  ProductScannerView.swift
//
//
//  Created by Dong on 2024/2/8.
//

import SwiftData
import SwiftUI

struct ProductScannerView: View {
    @EnvironmentObject var shoppingCart: ShoppingCart
    @ObservedObject var scanner: ProductScanner

    @State var scanResult = ""
    @State var productSheetIsShow = false
    @State var errorAlertIsShow = false
    
    init(modelContext: ModelContext) {
        scanner = ProductScanner(modelContext: modelContext)
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                GeometryReader { gr in
                    RoundedRectangle(cornerRadius: 12)
                        .frame(
                            width: min(min(gr.size.width, gr.size.height), 500),
                            height: min(min(gr.size.width, gr.size.height), 500)
                        )
                        .overlay {
                            Scanner { result in
                                switch result {
                                    case .success(let success):
                                        if(!productSheetIsShow) {
                                            scanResult = success
                                        }
                                    case .failure(let failure):
                                        scanner.error = .internalError(failure)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                }
                .scaledToFit()
                
                Text("Barcode: \(scanResult)")
                
                Spacer()
            }
            .padding()
            .navigationTitle("Scanner")
            .sheet(isPresented: $productSheetIsShow, onDismiss: { scanResult = "" }) {
                if let product = scanner.product {
                    ProductDetailView(product: product)
                }
            }
            .onChange(of: scanResult) {
                if(scanResult != "") {
                    scanner.barCode = scanResult
                    if(scanner.searchBarcode()) {
                        if(scanner.fetchProduct()) {
                            productSheetIsShow.toggle()
                        } else {
                            scanner.error = .fetchError
                            errorAlertIsShow.toggle()
                        }
                    } else {
                        scanner.error = .notFound(scanner.barCode)
                        errorAlertIsShow.toggle()
                    }
                }
            }
            .alert(scanner.error?.description() ?? "", isPresented: $errorAlertIsShow) {
                Button("OK") {
                    errorAlertIsShow.toggle()
                    scanResult = ""
                }
            }
            .overlay {
                if(!shoppingCart.cart.isEmpty) {
                    VStack {
                        Spacer()
                        ShoppingCartButton()
                    }
                }
            }
        }
        

    }
    
    indirect enum ScannerError: Error, LocalizedError {
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

#Preview {
    let container: ModelContainer
    do {
        let schema = Schema([Product.self, Order.self, OrderProduct.self])
        container = try ModelContainer(for: schema)
    } catch let error {
        fatalError(error.localizedDescription)
    }
    
    return ProductScannerView(modelContext: container.mainContext)
        .environmentObject(ShoppingCart())
}
