//
//  ProductDetailView.swift
//  SimPOS
//
//  Created by Dong on 2024/2/4.
//

import SwiftData
import SwiftUI

struct ProductDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var shoppingCart: ShoppingCart
    
    @State var amount: Int = 1
    @State var amountIsOverStorage: Bool = false
    @State var isDeleteAlertShow = false
    @State var productToEdit: Product?
    
    var product: Product
    var inCartAmount: Int { shoppingCart.getItemAmount(product) }
    let delete: (Product) -> Void
    
    var body: some View {
        GeometryReader { gr in
            VStack(alignment: .leading) {
                DataImage(data: product.imageData)
                    .scaledToFill()
                    .frame(maxHeight: gr.size.height/2)
                    .clipped()
                productInfo
                Spacer()
                amountStepper
                Spacer()
                addToCartButton
            }
        }
        .ignoresSafeArea(edges: .top)
        .overlay { navigationBar }
        .sheet(item: $productToEdit) { editingProduct in
            EditProductSheet(
                product: editingProduct,
                selectedImageData: editingProduct.imageData,
                title: "Update product"
            )
        }
    }
    
    var productInfo: some View {
        VStack(alignment: .leading) {
            Text(product.name)
                .font(.title)
                .fontWeight(.bold)
            
            CurrencyText(value: product.price)
                .font(.title2)
                .fontWeight(.medium)
        }
        .padding()
    }
    
    var amountStepper: some View {
        VStack {
            if let storage = product.storage {
                Text("Current storage: \(storage - inCartAmount)")
            }
            
            HStack(alignment: .center) {
                Button(action: { amount -= 1 }) {
                    Image(systemName: "minus")
                }
                .disabled(amount == 1)
                
                amountTextField
                
                Button(action: { amount += 1 }) {
                    Image(systemName: "plus")
                }
                .disabled(amount >= product.storage ?? .max - inCartAmount)
            }
            .frame(maxWidth: .infinity)
            .font(.title2)
            .fontWeight(.bold)
        }
    }
    
    var amountTextField: some View {
        TextField("", value: $amount, format: .number)
            .keyboardType(.numberPad)
            .frame(maxWidth: 60)
            .multilineTextAlignment(.center)
            .background {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(amountIsOverStorage ? .red : .gray)
            }
            .onChange(of: amount) { oldValue, newValue in
                if let storage = product.storage {
                    amountIsOverStorage = amount > storage - inCartAmount
                }
            }
    }
    
    var addToCartButton: some View {
        Button(action: {
            shoppingCart.addToCart(ShoppingCartItem(product: product, amount: amount))
            dismiss()
        }) {
            Text("Add to shop cart.")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .fontWeight(.medium)
        }
        .buttonStyle(.borderedProminent)
        .padding()
        .disabled(amount <= 0 || amountIsOverStorage)
    }
    
    var navigationBar: some View {
        VStack {
            HStack{
                if(UIDevice.current.systemName != "iPadOS"){
                    navigationBarButton("chevron.backward", action: { dismiss() })
                }
                Spacer()
                
                navigationBarButton("square.and.pencil", action: { productToEdit = product })
                
                navigationBarButton("trash", action: { isDeleteAlertShow.toggle() })
                    .tint(.red)
                    .confirmationDialog("Delete \(product.name)", isPresented: $isDeleteAlertShow) {
                        Button("Delete", role: .destructive) {
                            let productToDelete = product
                            delete(productToDelete)
                            dismiss()
                        }
                    } message: {
                        Text("Are you sure to delete product: \(product.name)")
                    }
            }
            
            Spacer()
        }
        .foregroundStyle(.tint)
        .fontWeight(.medium)
        .padding()
    }
    
    func navigationBarButton(_ systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
        }
        .padding(8)
        .background(.background)
        .clipShape(Circle())
    }
}
