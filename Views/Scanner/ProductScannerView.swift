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

    @State var productSheetIsShow = false
    @State var errorAlertIsShow = false
    @ObservedObject var scanner: ProductScanner
    
    init(modelContext: ModelContext) {
        scanner = ProductScanner(modelContext: modelContext)
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                GeometryReader { gr in
                    RoundedRectangle(cornerRadius: 12)
                        .frame(width: gr.size.width, height: gr.size.width)
                        .overlay {
                            Scanner { result in
                                switch result {
                                    case .success(let success):
                                        scanner.barCode = success
                                    case .failure(let failure):
                                        scanner.error = .internalError(failure)
                                }
                            }
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                }
                .scaledToFit()
                
                Text(scanner.barCode)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Scanner")
            .sheet(isPresented: $productSheetIsShow, onDismiss: { scanner.barCode = "" }) {
                ProductDetailView(product: self.scanner.product!)
            }
            .onChange(of: scanner.barCode) {
                if(scanner.barCode != "") {
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
                    scanner.barCode = ""
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
