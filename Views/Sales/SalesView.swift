//
//  SalesView.swift
//
//
//  Created by Dong on 2024/2/17.
//

import Charts
import SwiftData
import SwiftUI

struct SalesView: View {
    @ObservedObject var sales: Sales
    @State var isCostPopoverShow = false
    
    init(modelContext: ModelContext) {
        self.sales = Sales(modelContext: modelContext)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Picker("Date Range", selection: $sales.selectedDateRange) {
                ForEach(DateRangeOption.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: sales.selectedDateRange) {
                sales.dateRangeOptionChange()
            }
            
            HStack {
                Button(action: { sales.previous() }) {
                    Image(systemName: "chevron.left")
                }
                HStack(spacing: 0) {
                    switch sales.selectedDateRange {
                        case .day:
                            Text(sales.startOfDate, format: .dateTime.year().month().day())
                        case .week:
                            Text(sales.startOfDate, format: .dateTime.month().day())
                            Text(" - ")
                            if(sales.startOfDate.getMonth() == sales.endOfDate.getMonth()) {
                                Text(sales.endOfDate, format: .dateTime.day())
                            } else {
                                Text(sales.endOfDate, format: .dateTime.month().day())
                            }
                        case .month:
                            Text(sales.startOfDate, format: .dateTime.year().month())
                    }
                }
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                Button(action: { sales.next() }) {
                    Image(systemName: "chevron.right")
                }
                .disabled(!sales.hasNext)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            
            SalesPieChart(income: sales.income, cost: sales.cost)
                .aspectRatio(1, contentMode: .fill)
                .padding()
            
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text("Income")
                        .font(.footnote)
                    Text(sales.income, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                Divider()
                    .frame(height: 80)
                    .padding(.horizontal)
                VStack(alignment: .leading) {
                    HStack(spacing: 4) {
                        Text("Cost")
                        Button { isCostPopoverShow.toggle() } label: {
                           Image(systemName: "questionmark.circle")
                                .foregroundStyle(.gray)
                        }
                        .alert(isPresented: $isCostPopoverShow) {
                            Alert(title: Text("About Cost"), message: Text("Products with no cost given will be calculate as 0."))
                        }
                    }
                    .font(.footnote)
                    Text(sales.cost, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .font(.title2)
                    .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            
            Chart {
                BarMark(x: .value("Time", sales.startOfDate), y: .value("Sales", 0))
                ForEach(sales.orders, id: \.createTime) {
                    BarMark(
                        x: .value("Time", $0.createTime ..< $0.createTime.advanced(by: sales.selectedDateRange.getTimeInterval())),
                        y: .value("Sales", $0.subtotal)
                    )
                }
                BarMark(x: .value("Time", sales.endOfDate), y: .value("Sales", 0))
            }
            .chartXAxis {
                switch sales.selectedDateRange {
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
            .padding(.horizontal)
        }
        .padding()
    }
    
    
}

#Preview {
    let container: ModelContainer
    do {
        let schema = Schema([Product.self, Order.self, OrderProduct.self])
        container = try ModelContainer(for: schema)
    } catch let error {
        fatalError(error.localizedDescription)
    }
    
    return SalesView(modelContext: container.mainContext)
}
