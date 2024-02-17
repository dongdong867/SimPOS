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
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var shoppingCart: ShoppingCart
    
    @State var amount: Int = 0
    @State var amountIsOverStorage: Bool = false
    @State var isDeleteAlertShow = false
    @State var productToEdit: Product?
    
    var product: Product
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
            
            Text(
                product.price,
                format: .currency(code: Locale.current.currency?.identifier ?? "USD")
            )
            .font(.title2)
            .fontWeight(.medium)
        }
        .padding()
    }
    
    var amountStepper: some View {
        VStack {
            if let storage = product.storage {
                Text("Current storage: \(storage)")
            }
            
            HStack {
                Spacer()
                Button(action: { amount -= 1 }) {
                    Image(systemName: "minus")
                }
                .disabled(amount == 0)
                
                TextField("", value: $amount, format: .number)
                    .keyboardType(.numberPad)
                    .frame(maxWidth: 60)
                    .padding(4)
                    .multilineTextAlignment(.center)
                    .background {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(amountIsOverStorage ? .red : .gray)
                    }
                    .onChange(of: amount) { oldValue, newValue in
                        amountIsOverStorage = amount > product.storage ?? amount+1
                    }
                
                Button(action: { amount += 1 }) {
                    Image(systemName: "plus")
                }
                .disabled(amountIsOverStorage)
                Spacer()
            }
            .font(.title2)
            .fontWeight(.bold)
        }
    }
    
    var addToCartButton: some View {
        Button(action: {
            shoppingCart.addToCart(ShoppingCart.ShoppingCartItem(product: product, amount: amount))
            dismiss()
        }) {
            Text("Add to shop cart.")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .fontWeight(.medium)
        }
        .buttonStyle(.borderedProminent)
        .padding()
        .disabled(amount == 0 || amountIsOverStorage)
    }
    
    var navigationBar: some View {
        VStack {
            HStack{
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.backward")
                }
                .padding(8)
                .background(.background)
                .clipShape(Circle())
                
                Spacer()
                
                Button("Edit") {
                    productToEdit = product
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
                .background(.background)
                .clipShape(Capsule())
                
                Button(action: { isDeleteAlertShow.toggle() }) {
                    Image(systemName: "trash")
                }
                .tint(.red)
                .padding(8)
                .background(.background)
                .clipShape(Circle())
                .alert("Delete \(product.name)", isPresented: $isDeleteAlertShow) {
                    Button("Delete", role: .destructive) {
                        let productToDelete = product
                        delete(productToDelete)
                    dismiss()
                    }
                } message: {
                    Text("Deleting product will remove all data contains product \(product.name).")
                }
            }
            
            Spacer()
        }
        .foregroundStyle(.tint)
        .fontWeight(.medium)
        .padding()
    }
}
