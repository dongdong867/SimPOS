//
//  ShoppingCartDetail.swift
//
//
//  Created by Dong on 2024/2/6.
//

import SwiftUI

struct ShoppingCartDetail: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var shoppingCart: ShoppingCart
    @State var note: String = ""
    @State var subtotal: Float = 0
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(shoppingCart.cart) { item in
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
                                    subtotal += item.total
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding()
                }
                Divider()
            }
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
                        subtotal,
                        format: .currency(code: Locale.current.currency?.identifier ?? "USD")
                    )
                }
                .fontWeight(.bold)
            }
            .padding()
        }
        .overlay {
            VStack {
                Spacer()
                Button(action: { createOrder() }) {
                    Text("Create order")
                        .frame(maxWidth: .infinity)
                        .padding(8)
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
    }
    
    func createOrder() {
        let userDefault = UserDefaults.standard
        let orderNumber = userDefault.integer(forKey: "orderNumber")
        if(orderNumber < 100) {
            userDefault.setValue(orderNumber+1, forKey: "orderNubmer")
        } else {
            userDefault.setValue(0, forKey: "orderNumber")
        }
        
        let order = Order(
            orderNumber: orderNumber,
            createTime: Date(),
            orderProducts: [],
            addition: note,
            finished: false
        )
        modelContext.insert(order)
        
        for index in shoppingCart.cart.indices {
            let orderProduct = OrderProduct(
                product: shoppingCart.cart[index].product,
                order: order,
                amount: shoppingCart.cart[index].amount
            )
            modelContext.insert(orderProduct)
        }
        
        shoppingCart.clearCart()
        dismiss()
    }
}

#Preview {
    ShoppingCartDetail()
        .environmentObject(ShoppingCart())
}
