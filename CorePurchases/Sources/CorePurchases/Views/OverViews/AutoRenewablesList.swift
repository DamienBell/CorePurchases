//
//  SwiftUIView.swift
//  
//
//  Created by Damien Bell on 2/6/23.
//

import SwiftUI
import StoreKit

public struct AutoRenewablesList:View {
    
    @ObservedObject var store:Store
    
    public var body: some View {
        List {
            ForEach(store.subscriptionGroups(), id: \.id) { group in
                SubscriptionGroupDebug(group: group, store: store)
            }
        }
    }
    
    public init(store: Store) {
        self.store = store
    }
}
