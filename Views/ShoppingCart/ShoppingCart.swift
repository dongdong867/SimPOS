//
//  ShoppingCart.swift
//
//
//  Created by Dong on 2024/2/6.
//

import SwiftData
import SwiftUI

final class ShoppingCart: ObservableObject {
    @Published var cart = [ShoppingCartItem]()
    @Published var subtotal: Float = 0
    
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func getItemIndex(_ item: ShoppingCartItem) -> Int {
        if let index = cart.firstIndex(where: { $0.id == item.id }) {
            return index
        }
        return -1
    }
    
    func getItemAmount(_ product: Product) -> Int {
        if let index = cart.firstIndex(where: { $0.id == product }) {
            return cart[index].amount
        }
        return 0
    }
    
    func addToCart(_ item: ShoppingCartItem) {
        let index = getItemIndex(item)
        subtotal += Float(item.amount) * item.product.price
        if(index == -1) {
            cart.append(item)
        } else {
            cart[index].amount += item.amount
        }
    }
    
    func removeFromCart(_ itemToRemove: ShoppingCartItem) {
        cart.remove(at: getItemIndex(itemToRemove))
        subtotal -= itemToRemove.total
    }
    
    func createOrder(subtotal: Float, note: String) {
        let userDefault = UserDefaults.standard
        let orderNumber = userDefault.integer(forKey: "orderNumber")
        if(orderNumber < 100) {
            userDefault.setValue(orderNumber+1, forKey: "orderNumber")
        } else {
            userDefault.setValue(0, forKey: "orderNumber")
        }
        
        let order = Order(
            createTime: Date(),
            orderNumber: orderNumber,
            subtotal: subtotal,
            note: note,
            finished: false
        )
        modelContext.insert(order)
        
        for index in cart.indices {
            if(cart[index].product.storage != nil) {
                cart[index].product.storage! -= cart[index].amount
            }
            
            let orderProduct = OrderProduct(
                product: cart[index].product,
                order: order,
                amount: cart[index].amount
            )
            modelContext.insert(orderProduct)
        }
        
        clearCart()
    }
    
    func clearCart() {
        cart.removeAll()
        subtotal = 0
    }
}

struct ShoppingCartItem: Identifiable {
    var product: Product
    var amount: Int
    var total: Float { product.price * Float(amount) }
    
    var id: Product { product }
}
