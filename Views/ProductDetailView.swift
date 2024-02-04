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
    @State var amount: Int = 0

    let product: Product
    
    
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
        HStack {
            Spacer()
            Button(action: { amount -= 1 }) {
                Image(systemName: "minus")
            }
            
            TextField("", value: $amount, format: .number)
                .keyboardType(.numberPad)
                .frame(maxWidth: 60)
                .padding(.vertical, 4)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
                .background {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(.gray)
                }
            
            Button(action: { amount += 1 }) {
                Image(systemName: "plus")
            }
            Spacer()
        }
        .font(.title2)
        .fontWeight(.bold)
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
                
                Button(action: {}) {
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
