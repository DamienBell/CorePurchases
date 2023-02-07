//
//  StoreNavigation.swift
//  StoreKitDemo
//
//  Created by Damien Bell on 2/6/23.
//

import SwiftUI
import CorePurchases

struct StoreNavigation:View {
    
    let appStore:Store = Store(identifiers:["com.lifetime.unlock",
                                            "com.monies.id",
                                            "com.remove.ads",
                                            "com.secondary.monthly.subscription",
                                            "com.non.renewable.subscription",
                                             "com.weekly.unlock",
                                             "com.yearly.unlock"])
    var body: some View {
        NavigationView {
            List {
                Section("Products") {
                    
                    NavigationLink {
                        NonConsumablesList(store: appStore)
                    } label: {
                        Text("Non-Consumables")
                    }
                    
                    NavigationLink {
                        ConsumablesList(store: appStore)
                    } label: {
                        Text("Consumables")
                    }
                    
                    NavigationLink {
                        AutoRenewablesList(store: appStore)
                    } label: {
                        Text("Auto-Renewables")
                    }
                    
                    NavigationLink {
                        NonRenewablesList(store: appStore)
                    } label: {
                        Text("Non-Renewable Subscriptions")
                    }
                }
                
                Section("Transactions") {
                    NavigationLink {
                        EntitlementsList(store: appStore)
                    } label: {
                        Text("Entitlements")
                    }
                }
            }
        }
    }
}
