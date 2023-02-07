//
//  SwiftUIView.swift
//  
//
//  Created by Damien Bell on 2/6/23.
//

import SwiftUI
import StoreKit

public struct EntitlementsList:View {
    
    let store:Store
    
    public var body: some View {
        List {
            Section("Entitlement Transactions") {
                ForEach(store.entitlements.results(), id: \.id) { transaction in
                    TransactionDebug(transaction: transaction)
                }
            }
        }
    }
    
    public init(store: Store) {
        self.store = store
    }
}
