//
//  ShoppingCartButton.swift
//  
//
//  Created by Dong on 2024/2/6.
//

import SwiftUI

struct ShoppingCartButton: View {
    var body: some View {
        NavigationLink {
            ShoppingCartDetail()
                .navigationTitle("Shopping Cart")
        } label: {
            Text("Shopping cart")
                .padding()
                .frame(maxWidth: .infinity)
                .background(.tint)
                .foregroundStyle(.white)
                .fontWeight(.medium)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding()
        }

    }
}

#Preview {
    ShoppingCartButton()
}
