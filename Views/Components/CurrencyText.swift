//
//  CurrencyText.swift
//  
//
//  Created by Dong on 2024/2/21.
//

import SwiftUI

struct CurrencyText: View {
    let value: Float
    
    var body: some View {
        Text(
            value,
            format: .currency(code: Locale.current.currency?.identifier ?? "USD")
        )
    }
}
