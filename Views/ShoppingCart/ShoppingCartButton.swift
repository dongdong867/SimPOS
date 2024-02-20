//
//  ShoppingCartButton.swift
//  
//
//  Created by Dong on 2024/2/6.
//

import SwiftData
import SwiftUI

struct ShoppingCartButton: View {
    @State var isSheetShow = false
    
    var body: some View {
        if(UIDevice.current.systemName == "iPadOS") {
            Button(action: { isSheetShow.toggle() }) {
                buttonLabel
            }
            .sheet(isPresented: $isSheetShow) {
                ShoppingCartDetail()
            }
        } else {
            NavigationLink {
                ShoppingCartDetail()
            } label: {
                buttonLabel
            }
        }
    }
    
    var buttonLabel: some View {
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
