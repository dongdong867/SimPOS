import SwiftData
import SwiftUI

@main
struct MyApp: App {
    @StateObject var shoppingCart: ShoppingCart
    let container: ModelContainer
    
    init() {
        if(UserDefaults.standard.integer(forKey: "orderNumber") == 0){
            UserDefaults.standard.setValue(1, forKey: "orderNumber")
        }
        do {
            let schema = Schema([Product.self, Order.self, OrderProduct.self])
            container = try ModelContainer(for: schema)
            
            let cart = ShoppingCart(modelContext: container.mainContext)
            _shoppingCart = StateObject(wrappedValue: cart)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                ProductsView(modelContext: container.mainContext)
                    .environmentObject(shoppingCart)
                    .tabItem {
                        Image(systemName: "cart.fill")
                        Text("Products")
                    }
                
                ProductScannerView(modelContext: container.mainContext)
                    .environmentObject(shoppingCart)
                    .tabItem {
                        Image(systemName: "barcode.viewfinder")
                        Text("Scanner")
                    }
                
                OrdersView()
                    .tabItem {
                        Image(systemName: "list.clipboard.fill")
                        Text("Orders")
                    }
                
                SalesView(modelContext: container.mainContext)
                    .tabItem {
                        Image(systemName: "dollarsign.circle.fill")
                        Text("Sales")
                    }
            }
        }
        .modelContainer(container)
    }
}
