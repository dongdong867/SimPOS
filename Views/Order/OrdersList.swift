//
//  OrdersList.swift
//
//
//  Created by Dong on 2024/2/8.
//

import SwiftData
import SwiftUI

struct OrdersList: View {
    @Query(sort: \Order.createTime, order: .reverse) var orders: [Order]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(orders) { order in
                        Divider()
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("No. \(order.orderNumber)")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                if(order.finished) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                }
                                
                            }
                            VStack {
                                ForEach(order.orderProducts) { item in
                                    HStack {
                                        HStack {
                                            Text(item.product.name)
                                            Text("X\(item.amount)")
                                        }
                                        Spacer()
                                        Text(
                                            item.product.price * Float(item.amount),
                                            format: .currency(code: Locale.current.currency?.identifier ?? "USD")
                                        )
                                    }
                                }
                                Divider()
                            }
                            .padding(.leading, 8)
                            if(!order.note.isEmpty) {
                                Text(order.note)
                                    .font(.callout)
                                    .foregroundStyle(.gray)
                            }
                            HStack {
                                Text("Subtotal")
                                Spacer()
                                Text(order.subtotal, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                            }
                            .font(.headline)
                            Text(order.createTime, format: .dateTime)
                                .font(.footnote)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(8)
                    }
                }
                .padding(.horizontal)
                .navigationTitle("Orders")
            }
        }
    }
}

#Preview {
    OrdersList()
        .modelContainer(for: [Product.self, Order.self, OrderProduct.self])
}
