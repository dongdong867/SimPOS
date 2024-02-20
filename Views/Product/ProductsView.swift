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
    let isIPad = UIDevice.current.systemName == "iPadOS"
    
    init(modelContext: ModelContext) {
        products = ProductList(modelContext: modelContext)
    }
    
    var body: some View {
        Group {
            if isIPad {
                NavigationSplitView(columnVisibility: $sidebarVisibility) {
                    productList
                        .toolbar(removing: .sidebarToggle)
                } detail: {
                    spiltViewDetail
                        .navigationBarBackButtonHidden()
                }
                .navigationSplitViewStyle(.balanced)
            } else {
                NavigationStack {
                    productList
                }
            }
        }
        .searchable(text: $search)
        .onAppear { products.fetchProducts(with: search) }
        .onChange(of: search) {
            products.fetchProducts(with: search)
        }
    }
    
    @ViewBuilder
    var productList: some View {
        if(products.products.isEmpty) { emptyStoragePlaceholder }
        GeometryReader { gr in
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: cardSizeThatFits(for: gr.size)))], alignment: .leading) {
                    ForEach(products.products) { product in
                        if isIPad {
                            productCard(product)
                                .onTapGesture { selectedProduct = product }
                        } else {
                            defaultProductCard(product)
                        }
                    }
                }
            }
            .scrollClipDisabled()
        }
        .navigationTitle("Products")
        .padding(.horizontal)
        .toolbar { toolbar }
        .overlay { shoppingCartButton }
    }
    
    var emptyStoragePlaceholder: some View {
        ContentUnavailableView(
            "No products found.",
            systemImage: "tray.fill",
            description: Text("Click plus button to create products.")
        )
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
    
    var shoppingCartButton: some View {
        VStack {
            if(!shoppingCart.cart.isEmpty) {
                Spacer()
                ShoppingCartButton()
            }
        }
    }
    
    @ViewBuilder
    var spiltViewDetail: some View {
        if(selectedProduct != nil) {
            ProductDetailView(product: selectedProduct!) { productToDelete in
                products.deleteProduct(productToDelete)
                products.fetchProducts(with: search)
                selectedProduct = nil
            }
        } else {
            Text("No selected product.")
        }
    }
    
    func defaultProductCard(_ product: Product) -> some View {
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
        .environmentObject(ShoppingCart(modelContext: container.mainContext))
}
