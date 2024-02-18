//
//  ShoppingCartDetail.swift
//
//
//  Created by Dong on 2024/2/6.
//

import SwiftData
import SwiftUI

struct ShoppingCartDetail: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var shoppingCart: ShoppingCart
    
    @State var note: String = ""
    
    var body: some View {
        VStack {
            cartList
            orderInfo
            Spacer(minLength: 80)
        }
        .overlay {
            createOrderButton
        }
    }
    
    var cartList: some View {
        List(shoppingCart.cart) { item in
            HStack(spacing: 12) {
                DataImage(data: item.product.imageData)
                    .frame(maxWidth: 100)
                VStack(alignment: .leading) {
                    Text(item.product.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Amount: \(item.amount)")
                    HStack {
                        Spacer()
                        Text(
                            item.total,
                            format: .currency(code: Locale.current.currency?.identifier ?? "USD")
                        )
                        .fontWeight(.semibold)
                        .onAppear {
                            shoppingCart.subtotal += item.total
                        }
                    }
                }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    shoppingCart.removeFromCart(item)
                    if(shoppingCart.cart.isEmpty) {
                        dismiss()
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .listStyle(.plain)
    }
    
    var orderInfo: some View {
        VStack(alignment: .leading) {
            Label("Notes", systemImage: "note.text")
            TextField("Add notes here.", text: $note)
                .textFieldStyle(.roundedBorder)
            Divider()
                .padding(.vertical)
            HStack {
                Label("Subtotal", systemImage: "dollarsign.circle")
                Spacer()
                Text(
                    shoppingCart.subtotal,
                    format: .currency(code: Locale.current.currency?.identifier ?? "USD")
                )
            }
            .fontWeight(.bold)
        }
        .padding()
    }
    
    var createOrderButton: some View {
        VStack {
            Spacer()
            Button{
                shoppingCart.createOrder(subtotal: shoppingCart.subtotal, note: note)
                dismiss()
            } label: {
                Text("Create order")
                    .frame(maxWidth: .infinity)
                    .padding(8)
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
}
