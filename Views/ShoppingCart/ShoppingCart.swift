//
//  ShoppingCart.swift
//
//
//  Created by Dong on 2024/2/6.
//

import SwiftUI

class ShoppingCart: ObservableObject {
    
    @Published var cart = [ShoppingCartItem]()
    
    struct ShoppingCartItem: Identifiable {
        var product: Product
        var amount: Int
        var total: Float { product.price * Float(amount) }
        
        var id: Product { product }
    }
    
    func getItemIndex(_ item: ShoppingCartItem) -> Int {
        if let index = cart.firstIndex(where: { $0.id == item.id }) {
            return index
        }
        return -1
    }
    
    func addToCart(_ item: ShoppingCartItem) {
        if(item.product.storage != nil) {
            item.product.storage! -= item.amount
        }
        
        let index = getItemIndex(item)
        if(index == -1) {
            cart.append(item)
        } else {
            cart[index].amount += item.amount
        }
    }
    
    func updateCart(_ item: ShoppingCartItem) {
        let index = getItemIndex(item)
        cart[index] = item
    }
    
    func removeFromCart(_ itemToRemove: ShoppingCartItem) {
        let index = getItemIndex(itemToRemove)
        cart.remove(at: index)
    }
    
    func clearCart() {
        cart.removeAll()
    }
}
