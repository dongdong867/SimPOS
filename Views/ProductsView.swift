//
//  ProductView.swift
//  SimPOS
//
//  Created by Dong on 2024/1/31.
//

import SwiftData
import SwiftUI

struct ProductsView: View {
    @State var search: String = ""
    @State var isShowingSheet = false
    
    @Query var products: [Product]
    
    init() {
        _products = Query(
            filter: #Predicate<Product> {
                if(search.isEmpty) { true }
                else { $0.name.contains(search) }
            },
            sort: [SortDescriptor(\Product.name)]
        )
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(), GridItem()]) {
                    ForEach(products) { product in
                        ProductCard(product: product)
                    }
                }
                .navigationTitle("Products")
                .toolbar(content: {
                    ToolbarItemGroup {
                        Button {
                            isShowingSheet.toggle()
                        } label: {
                            Image(systemName: "plus")
                        }
                        .sheet(isPresented: $isShowingSheet) {
                            CreateProductSheet()
                                .presentationDragIndicator(.visible)
                        }
                    }
                })
                .searchable(text: $search)
            }
            .overlay {
                if(products.isEmpty && search.isEmpty) {
                    VStack {
                        Spacer()
                        Image(systemName: "tray.fill")
                            .imageScale(.large)
                            .font(.largeTitle)
                            .padding(.bottom)
                        Group {
                            Text("No products found in storage.")
                            Text("Click plus button to create products.")
                        }
                        .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .foregroundStyle(.gray)
                }
            }
        }
    }
}

#Preview {
    ProductsView()
        .modelContainer(for: [Product.self, Order.self, OrderProduct.self])
}
