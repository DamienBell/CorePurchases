//
//  SwiftUIView.swift
//  
//
//  Created by Damien Bell on 2/6/23.
//

import SwiftUI
import StoreKit


public struct NonRenewablesList:View {
    
    @ObservedObject var store:Store
    
    
    public var body:some View {
        List {
            
            Section("Non-Renewable Subscriptions") {
                ForEach(store.nonRenewingSubscriptions(), id: \.id) { product in
                    DebugProductCell(product: product) {
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

