//
//  ContentView.swift
//  StoreKitDemo
//
//  Created by Damien Bell on 1/30/23.
//

import SwiftUI
import CorePurchases



//TODO:
 //Create a Store([productIds])
    // - ensure listener
    // - fetch product info
    // - sort products by type (autorenew, nonconsumable, consubable, ect)
    // - run Transactions
    // - store/update transactions locally
    // - build Subscription Groups
        // - get the state of each group
    
struct ContentView: View {
    
    @EnvironmentObject var appStore:Store
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
