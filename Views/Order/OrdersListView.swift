//
//  OrdersListView.swift
//
//
//  Created by Dong on 2024/2/8.
//

import SwiftData
import SwiftUI

struct OrdersListView: View {
    @Query(sort: \Order.createTime, order: .reverse) var orders: [Order]
    @State var sortWith: SortWith = .time
    
    var body: some View {
        NavigationStack {
            List(orders) { order in
                orderListItem(order)
            }
            .navigationTitle("Orders")
            .toolbar {
                Menu {
                    Picker("sortWith", selection: $sortWith) {
                        ForEach(SortWith.allCases, id: \.self) {
                            Label($0.getCaseDescription(), systemImage: $0.getCaseSystemImageName())
                        }
                    }
                } label: {
                    Label("sort", systemImage: "line.3.horizontal.decrease.circle")
                }
            }
        }
    }
    
    enum SortWith: String, CaseIterable {
        case time, finished
        
        func getCaseDescription() -> String {
            switch self {
                case .time:
                    return "Latest"
                case .finished:
                    return "Unfinished"
            }
        }
        
        func getCaseSystemImageName() -> String {
            switch self {
                case .time:
                    return "clock"
                case .finished:
                    return "checkmark.circle"
            }
        }
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
                    HStack {
                        Text(item.product.name)
                        Text("x\(item.amount)")
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
            Text(order.subtotal, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
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
    OrdersListView()
        .modelContainer(for: [Product.self, Order.self, OrderProduct.self])
}
