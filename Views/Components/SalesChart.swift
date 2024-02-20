//
//  SalesChart.swift
//  
//
//  Created by Dong on 2024/2/21.
//

import Charts
import SwiftUI

struct SalesChart: View {
    let startOfDate: Date
    let endOfDate: Date
    let orders: [Order]
    let selectedDateRange: DateRangeOption
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Sales chart")
                .font(.caption)
                .foregroundStyle(.gray.opacity(0.6))
            
            Chart {
                BarMark(x: .value("Time", startOfDate), y: .value("Sales", 0))
                BarMark(x: .value("Time", endOfDate), y: .value("Sales", 0))
                
                ForEach(orders, id: \.createTime) {
                    BarMark(
                        x: .value("Time", $0.createTime ..< $0.createTime.advanced(by: selectedDateRange.getTimeInterval())),
                        y: .value("Sales", $0.subtotal)
                    )
                }
            }
            .chartXAxis { salesChartXAxis }
        }
    }
    
    @AxisContentBuilder
    var salesChartXAxis: some AxisContent {
        switch selectedDateRange {
            case .day:
                AxisMarks(values: .stride(by: .hour, count: 6)) { value in
                    AxisValueLabel(format: .dateTime.hour())
                    AxisGridLine()
                    AxisTick()
                }
                
            case .week:
                AxisMarks(values: .stride(by: .day, count: 1)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                    AxisGridLine()
                    AxisTick()
                }
                
            case .month:
                AxisMarks(values: .stride(by: .day, count: 7)) { value in
                    if let date = value.as(Date.self) {
                        let day = Calendar.current.component(.day, from: date)
                        switch day {
                            case 1:
                                AxisValueLabel(format: .dateTime.month().day())
                            default:
                                AxisValueLabel(format: .dateTime.day())
                        }
                    }
                    AxisGridLine()
                    AxisTick()
                }
        }
    }
}
