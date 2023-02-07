//
//  File.swift
//  
//
//  Created by Damien Bell on 2/6/23.
//

import SwiftUI
import StoreKit

struct RenewalStateDebug:View {
    let state:Product.SubscriptionInfo.RenewalState
    var body: some View {
        HStack {
            Text("RenewalState: ")
                .fontWeight(.bold)
            Text(state.display)
                .underline()
        }
    }
    
}
