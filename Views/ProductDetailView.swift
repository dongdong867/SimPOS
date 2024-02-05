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
    
    @State var amount: Int = 0
    @State var amountIsOverStorage: Bool = false
    @State var productToEdit: Product?

    var product: Product
    
    
    var body: some View {
        VStack(alignment: .leading) {
            ProductImage(data: product.imageData)
                .scaledToFit()
            productInfo
            Spacer()
            amountStepper
            Spacer()
            addToCartButton
        }
        .edgesIgnoringSafeArea(.top)
        .overlay {
            navigationBar
        }
        .sheet(item: $productToEdit) { editingProduct in
            EditProductSheet(
                product: editingProduct,
                selectedImageData: editingProduct.imageData, 
                title: "Update product"
            ) { _ in }
                .presentationDragIndicator(.visible)
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
        Button(action: {}) {
            Text("Add to shop cart.")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .fontWeight(.medium)
        }
        .buttonStyle(.borderedProminent)
        .padding(.horizontal)
        .disabled(amount == 0 || amountIsOverStorage)
    }
    
    var navigationBar: some View {
        VStack {
            HStack{
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.backward")
                        .imageScale(.large)
                }
                .padding(8)
                .background(.background)
                .clipShape(Circle())
                
                Spacer()
                
                Button(action: { productToEdit = product }) {
                    Text("Edit")
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
                .background(.background)
                .clipShape(Capsule())
            }
            
            Spacer()
        }
        .foregroundStyle(.tint)
        .fontWeight(.medium)
        .padding(.horizontal)
    }
}
