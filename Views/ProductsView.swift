//
//  ProductView.swift
//  SimPOS
//
//  Created by Dong on 2024/1/31.
//

import SwiftData
import SwiftUI

struct ProductsView: View {
    @Environment(\.modelContext) var modelContext
    
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
                                EditProductSheet(product: Product(
                                    imageData: nil,
                                    name: "",
                                    price: 0,
                                    cost: nil,
                                    storage: nil
                                )){
                                    modelContext.insert($0)
                                }
                                
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
            emptyStoragePlaceholder
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
        }
    }
    
    var emptyStoragePlaceholder: some View {
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
        .frame(minHeight: 200)
    }
    
    
}

#Preview {
    ProductsView()
        .modelContainer(for: [Product.self, Order.self, OrderProduct.self])
}
