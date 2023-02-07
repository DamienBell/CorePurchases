//
//  StoreKitDemoApp.swift
//  StoreKitDemo
//
//  Created by Damien Bell on 1/30/23.
//

import SwiftUI
import CorePurchases

@main
struct StoreKitDemoApp: App {

    let appStore:Store = Store(identifiers:["com.lifetime.unlock",
                                            "com.monies.id",
                                            "com.remove.ads",
                                            "com.secondary.monthly.subscription",
                                            "com.non.renewable.subscription",
                                             "com.weekly.unlock",
                                             "com.yearly.unlock"])
    
    var body: some Scene {
        WindowGroup {
            //StoreDebugView(store: appStore)
            StoreNavigation()
        }
    }
}
