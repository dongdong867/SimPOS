//
//  SalesView.swift
//
//
//  Created by Dong on 2024/2/17.
//

import SwiftData
import SwiftUI

struct SalesView: View {
    @ObservedObject var sales: Sales
    @State var isCostPopoverShow = false
    
    init(modelContext: ModelContext) {
        self.sales = Sales(modelContext: modelContext)
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { gr in
                ScrollView {
                    picker
                    pagination
                    if(gr.size.width > gr.size.height) {
                        iPadOSLayout
                    } else {
                        defaultLayout
                    }
                }
                .padding(.horizontal)
                .navigationTitle("Sales")
            }
        }
    }
    
    var picker: some View {
        Picker("Date Range", selection: $sales.selectedDateRange) {
            ForEach(DateRangeOption.allCases, id: \.self) { option in
                Text(option.rawValue.capitalized)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: sales.selectedDateRange) {
            sales.dateRangeOptionChange()
        }
    }
    
    var pagination: some View {
        HStack {
            Button(action: { sales.previous() }) {
                Image(systemName: "chevron.left")
            }
            dateRange
            Button(action: { sales.next() }) {
                Image(systemName: "chevron.right")
            }
            .disabled(!sales.hasNext)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.circle)
    }
    
    var iPadOSLayout: some View {
        VStack(spacing: 12) {
            HStack {
                VStack {
                    pieChart
                        .padding()
                    salesDetail
                }
                SalesChart(
                    startOfDate: sales.startOfDate,
                    endOfDate: sales.endOfDate,
                    orders: sales.orders,
                    selectedDateRange: sales.selectedDateRange
                )
            }
        }
    }
    
    var defaultLayout: some View {
        VStack(spacing: 12) {
            pieChart
            salesDetail
            SalesChart(
                startOfDate: sales.startOfDate,
                endOfDate: sales.endOfDate,
                orders: sales.orders,
                selectedDateRange: sales.selectedDateRange
            )
        }
    }
    
    var pieChart: some View {
        SalesPieChart(income: sales.income, cost: sales.cost)
            .aspectRatio(1, contentMode: .fill)
            .padding()
    }
    
    var salesDetail: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text("Income")
                    .font(.footnote)
                CurrencyText(value: sales.income)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            
            Divider()
                .frame(maxHeight: 60)
                .padding(.horizontal)
            
            VStack(alignment: .leading) {
                HStack(spacing: 4) {
                    Text("Cost")
                    costInfoButton
                }
                .font(.footnote)
                CurrencyText(value: sales.cost)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
    }
    
    var dateRange: some View {
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
    }
    
    var costInfoButton: some View {
        Button { isCostPopoverShow.toggle() } label: {
            Image(systemName: "questionmark.circle")
                .foregroundStyle(.gray)
        }
        .alert(isPresented: $isCostPopoverShow) {
            Alert(title: Text("Calculating details"), message: Text("Products with no cost given will be calculate as 0."))
        }
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
