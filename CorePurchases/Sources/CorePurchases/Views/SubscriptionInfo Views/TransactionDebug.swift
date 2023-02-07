//
//  File.swift
//  
//
//  Created by Damien Bell on 2/6/23.
//

import SwiftUI
import StoreKit

struct TransactionDebug:View {
    
    let transaction:StoreKit.Transaction
    
    var expirationString:String? {
        guard let expire = transaction.expirationDate else {
            return nil
        }
        return expire.formatted()
    }
        
    var body: some View {
        VStack(alignment: .leading) {

            Text(transaction.shortAutoRenewableDescription)
                .font(.caption)
                .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            
//            Text(transaction.debugDescription)
//                .font(.caption)
//                .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
        }
    }
}


extension StoreKit.Transaction {
    var shortAutoRenewableDescription:String {
        
        var open:String = "{\n"
        
        
        let close:String = "\n}"
        
        open += "\n transactionId: \(id),"
        open += "\n productId: \(productID)"
        
        if let _offertype = offerType?.localizedDescription {
            open += "\n offerType: \(_offertype)"
        }
        if let expiration = expirationDate?.formatted() {
            open += "\n expirationDate: \(expiration)"
        }
        
       // open += "\n will \(self.w)"
        return open + close
    }
}
