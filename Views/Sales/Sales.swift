//
//  Sales.swift
//  
//
//  Created by Dong on 2024/2/18.
//

import Charts
import SwiftData
import SwiftUI

final class Sales: ObservableObject {
    @Published var income: Float = 0
    @Published var cost: Float = 0
    @Published var selectedDateRange: DateRangeOption = .day
    @Published var hasNext = false
    @Published var salesData = [SalesData]()
    
    let modelContext: ModelContext
    var startOfDate: Date
    var endOfDate: Date
    var orders = [Order]()
    var descriptor: FetchDescriptor<Order> {
        FetchDescriptor<Order>(
            predicate: #Predicate { startOfDate <= $0.createTime && $0.createTime < endOfDate },
            sortBy: [.init(\.createTime)]
        )
    }
    
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.startOfDate = Date.now.getStartOfDay()
        self.endOfDate = startOfDate.advanced(by: 86_400)
        
        fetchOrder()
    }
    
    func fetchOrder() {
        orders = (try? modelContext.fetch(descriptor)) ?? []
        calculateOrders()
    }
    
    func dateRangeOptionChange() {
        clearData()
        switch selectedDateRange {
            case .day:
                startOfDate = Date.now.getStartOfDay()
                endOfDate = startOfDate.advanced(by: 86_400)
            case .week:
                startOfDate = Date.now.getStartOfWeek() ?? .now
                endOfDate = startOfDate.advanced(by: 604_800)
            case .month:
                startOfDate = Date.now.getStartOfMonth() ?? .now
                endOfDate = startOfDate.getEndOfMonth() ?? .now
        }
        hasNext = false
        fetchOrder()
    }
    
    func previous() {
        clearData()
        endOfDate = startOfDate
        switch selectedDateRange {
            case .day:
                startOfDate = startOfDate.advanced(by: -86_400)
            case .week:
                startOfDate = startOfDate.advanced(by: -604_800)
            case .month:
                startOfDate = endOfDate.advanced(by: -1).getStartOfMonth() ?? .now
        }
        
        if(Date.now > endOfDate) {
            hasNext = true
        }
        
        fetchOrder()
    }
    
    func next() {
        clearData()
        startOfDate = endOfDate
        switch selectedDateRange {
            case .day:
                endOfDate = endOfDate.advanced(by: 86_400)
            case .week:
                endOfDate = endOfDate.advanced(by: 604_800)
            case .month:
                endOfDate = endOfDate.getEndOfMonth() ?? .now
        }
        
        if(endOfDate > Date.now) {
            hasNext = false
        }
        fetchOrder()
    }
    
    func clearData() {
        income = 0
        cost = 0
        orders = []
        salesData = []
    }
    
    func calculateOrders() {
        guard !orders.isEmpty else { return }
        
        var subtotal: Float = 0
        var lastTime = orders[0].createTime
        
        for order in orders {
            for orderProduct in order.orderProducts {
                let productCost = orderProduct.product.cost ?? 0
                cost += Float(orderProduct.amount) * productCost
                income += Float(orderProduct.amount) * (orderProduct.product.price - productCost)
            }
            
            switch selectedDateRange {
                case .day:
                    if(lastTime.getHour() != order.createTime.getHour()) {
                        salesData.append(.init(time: lastTime, sales: subtotal))
                        subtotal = 0
                    }
                    
                    subtotal += order.subtotal
                    lastTime = order.createTime
                default:
                    if(order.createTime.timeIntervalSince(lastTime.getStartOfDay()) > 86_400) {
                        salesData.append(.init(time: lastTime, sales: subtotal))
                        subtotal = 0
                    }
                
                    subtotal += order.subtotal
                    lastTime = order.createTime
            }
        }
        
        salesData.append(.init(time: lastTime, sales: subtotal))
    }
}

enum DateRangeOption: String, CaseIterable {
    case day, week, month
}
