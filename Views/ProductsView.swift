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
        
    var body: some View {
        NavigationStack {
            ScrollView {
                ProductListView(searchQuery: search)
                .navigationTitle("Products")
                .padding()
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
        }
    }
}

struct ProductListView: View {
    @Query(sort: \Product.name) var products: [Product]
    
    var searchQuery: String
    
    init(searchQuery: String) {
        if(searchQuery.count > 0) {
            _products = Query(filter: #Predicate<Product> { $0.name.contains(searchQuery) })
        }
        self.searchQuery = searchQuery
    }
    
    var body: some View {
        if(products.isEmpty && searchQuery.isEmpty) {
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
        } else {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                ForEach(products) { product in
                    NavigationLink {
                        ProductDetailView(product: product)
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarBackButtonHidden()
                    } label: {
                        VStack {
                            ProductImage(data: product.imageData)
                            Text(product.name)
                        }
                        .tint(.primary)
                    }
                }
            }
        }    }
}

#Preview {
    ProductsView()
        .modelContainer(for: [Product.self, Order.self, OrderProduct.self])
}
