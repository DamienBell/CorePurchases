//
//  SwiftUIView.swift
//  
//
//  Created by Damien Bell on 2/6/23.
//

import SwiftUI
import StoreKit

public struct ConsumablesList:View {
    
    @ObservedObject var store:Store
    
    
    public var body:some View {
        List {
            Section("Consumables") {
                
                let quantity:Int = 5
                
                ForEach(store.consumables(), id: \.id) { product in
                    DebugConsumableProductCell(product: product, store: store, increment: quantity) {
                        purchaseQuantity(product: product, amount: quantity)
                    }
                }
            }
        }
    }
    
    public init(store: Store) {
        self.store = store
    }
    
    
    func purchaseQuantity(product: Product, amount: Int) {
        guard !store.activeTransaction.processing else {
            return
        }
        Task(priority: .userInitiated) {
            let response = await store.buy(consumable: product, quantity: 5)
            print(response)
        }
    }
}
