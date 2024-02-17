//
//  ProductView.swift
//  SimPOS
//
//  Created by Dong on 2024/1/31.
//

import SwiftData
import SwiftUI

struct ProductsView: View {
    @EnvironmentObject var shoppingCart: ShoppingCart
    @ObservedObject var products: ProductList
    
    @State var search: String = ""
    @State var selectedProduct: Product? = nil
    @State var isCreateProductSheetShow = false
    @State var sidebarVisibility = NavigationSplitViewVisibility.doubleColumn
    
    init(modelContext: ModelContext) {
        products = ProductList(modelContext: modelContext)
    }
    
    var body: some View {
        dynamicNavigationLayout
            .searchable(text: $search)
            .onChange(of: search) {
                products.fetchProducts(with: search)
            }
            .onAppear {
                products.fetchProducts(with: search)
            }
    }
    
    @ViewBuilder
    var dynamicNavigationLayout: some View {
        if(UIDevice.current.systemName == "iPadOS") {
            NavigationSplitView(columnVisibility: $sidebarVisibility) {
                if(products.products.isEmpty) { emptyStoragePlaceholder }
                
                sideBar
                    .navigationTitle("Products")
                    .scrollClipDisabled()
                    .padding(.horizontal)
                    .toolbar(removing: .sidebarToggle)
                    .toolbar { toolbar }
                    .overlay {
                        if(!shoppingCart.cart.isEmpty) {
                            VStack {
                                Spacer()
                                ShoppingCartButton()
                            }
                        }
                    }
            } detail: {
                if(selectedProduct != nil) {
                    ProductDetailView(product: selectedProduct!) { productToDelete in
                        products.deleteProduct(productToDelete)
                        products.fetchProducts(with: search)
                        selectedProduct = nil
                    }
                        .navigationBarBackButtonHidden()
                } else {
                    Text("No selected product.")
                }
            }
            .navigationSplitViewStyle(.balanced)
        } else {
            NavigationStack {
                if(products.products.isEmpty) { emptyStoragePlaceholder }
                
                GeometryReader { gr in
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: cardSizeThatFits(for: gr.size)))], alignment: .leading) {
                            ForEach(products.products) { product in
                                NavigationLink {
                                    ProductDetailView(product: product) { productToDelete in
                                        products.deleteProduct(productToDelete)
                                        products.fetchProducts(with: search)
                                    }
                                        .navigationBarBackButtonHidden()
                                } label: {
                                    productCard(product)
                                }
                            }
                        }
                    }
                    .scrollClipDisabled()
                }
                .navigationTitle("Products")
                .padding(.horizontal)
                .toolbar { toolbar }
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
    }
    
    var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                isCreateProductSheetShow.toggle()
            } label: {
                Image(systemName: "plus")
            }
            .sheet(isPresented: $isCreateProductSheetShow, onDismiss: { products.fetchProducts(with: "") }) {
                EditProductSheet(product: Product(
                    imageData: nil,
                    code: nil,
                    name: "",
                    price: 0,
                    cost: nil,
                    storage: nil
                )){ products.createProduct($0) }
            }
        }
    }
    
    var sideBar: some View {
        GeometryReader { gr in
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: cardSizeThatFits(for: gr.size)))], alignment: .leading) {
                    ForEach(products.products) { product in
                        productCard(product)
                            .onTapGesture { selectedProduct = product }
                    }
                }
            }
        }
    }
    
    var emptyStoragePlaceholder: some View {
        ContentUnavailableView(
            "No products found.",
            systemImage: "tray.fill",
            description: Text("Click plus button to create products.")
        )
    }
    
    func productCard(_ product: Product) -> some View {
        VStack {
            DataImage(data: product.imageData)
            Text(product.name)
        }
        .tint(.primary)
    }
    
    
    func cardSizeThatFits(for size: CGSize) -> Double {
        if(size.width < size.height) {
            return (size.width/3)
        } else {
            return (size.width/5)
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
    
    return ProductsView(modelContext: container.mainContext)
        .modelContainer(for: [Product.self, Order.self, OrderProduct.self])
        .environmentObject(ShoppingCart())
}
