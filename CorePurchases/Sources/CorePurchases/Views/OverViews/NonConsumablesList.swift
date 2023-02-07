//
//  SwiftUIView.swift
//  
//
//  Created by Damien Bell on 2/6/23.
//

import SwiftUI
import StoreKit

public struct NonConsumablesList:View {
    
    @ObservedObject var store:Store
    
    
    public var body:some View {
        List {
            
            Section("Non-Consumables") {
                ForEach(store.nonConsumables(), id: \.id) { product in
                    
                    DebugNonConsumableProductCell(product: product, store: store) {
                        guard !store.activeTransaction.processing else {
                            return
                        }
                        
                        Task(priority: .userInitiated) {
                            let response = await store.buy(product: product)
                            print("purchases: ", response)
                        }
                    }
                }
            }
        }
    }
    
    public init(store: Store) {
        self.store = store
    }
}


