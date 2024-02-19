//
//  SalesPieChart.swift
//  
//
//  Created by Dong on 2024/2/19.
//

import SwiftUI

struct SalesPieChart: View {
    var income: Float
    var cost: Float
    var totalSales: Float { income + cost }
    
    var body: some View {
        ZStack {
            GeometryReader { gr in
                Circle()
                    .stroke(lineWidth: gr.size.width/12)
                    .foregroundStyle(.gray.opacity(0.3))
                
                Circle()
                    .trim(from: 0, to: totalSales == 0 ? 0 : CGFloat(income/totalSales))
                    .rotation(.degrees(-90))
                    .stroke(style: .init(lineWidth: gr.size.width/12, lineCap: .round))
                    .foregroundStyle(.tint)
            }
            .scaledToFit()
            .frame(maxWidth: 400)
            
            VStack(alignment: .leading) {
                Text("Total sales")
                    .font(.footnote)
                Text(totalSales, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .font(totalSales > 1_000_000 ? .title : .largeTitle)
                    .fontWeight(.bold)
            }
        }
        .padding(.horizontal)
    }
}
