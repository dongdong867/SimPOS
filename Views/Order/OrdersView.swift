//
//  OrdersView.swift
//
//
//  Created by Dong on 2024/2/8.
//

import SwiftData
import SwiftUI

struct OrdersView: View {
    @Query(sort: \Order.createTime, order: .reverse) var orders: [Order]
    
    var body: some View {
        NavigationStack {
            List(orders) { order in
                orderListItem(order)
            }
            .navigationTitle("Orders")
            .overlay {
                if(orders.isEmpty) {
                    emptyPlaceholder
                }
            }
        }
    }
    
    var emptyPlaceholder: some View {
        VStack {
            Image(systemName: "clipboard.fill")
                .imageScale(.large)
                .font(.largeTitle)
                .padding(.bottom)
            Text("No orders found in storage.")
        }
        .foregroundStyle(.gray)
    }
    
    func orderListItem(_ order: Order) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            title(order)
            productList(order)
            if(!order.note.isEmpty){
                notes(order)
            }
            subtotal(order)
            createTime(order)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            if(!order.finished) {
                Button {
                    order.finished.toggle()
                } label: {
                    Image(systemName: "checkmark")
                }
                .tint(.green)
            }
        }
    }
    
    func title(_ order: Order) -> some View {
        HStack {
            if(order.finished) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
            Text("No. \(order.orderNumber)")
                .font(.title2)
                .fontWeight(.semibold)
        }
    }
    
    func productList(_ order: Order) -> some View {
        VStack {
            ForEach(order.orderProducts) { item in
                HStack {
                    Text("\(item.product.name) x\(item.amount)")
                    Spacer()
                    CurrencyText(value: item.product.price * Float(item.amount))
                }
            }
            Divider()
        }
        .padding(.leading, 8)
    }
    
    func notes(_ order: Order) -> some View {
        VStack(alignment: .leading) {
            Text("Note:")
            Text(order.note)
            Divider()
        }
        .font(.callout)
        .foregroundStyle(.gray)
        .padding(.leading, 8)
    }
    
    func subtotal(_ order: Order) -> some View {
        HStack {
            Text("Subtotal")
            Spacer()
            CurrencyText(value: order.subtotal)
        }
        .font(.headline)
        
    }
    
    func createTime(_ order: Order) -> some View {
        Text(order.createTime, format: .dateTime)
            .font(.footnote)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
}

#Preview {
    OrdersView()
        .modelContainer(for: [Product.self, Order.self, OrderProduct.self])
}
