//
//  File.swift
//  
//
//  Created by Damien Bell on 1/30/23.
//

import SwiftUI
import StoreKit

public struct SubscriptionGroup:Equatable, Hashable, Identifiable {
    
    public var id:String
    public var products:Set<Product> = .init()
        
    //MARK: Convenience Getters
    public var referenceName:String {
        return products.first?.subscription?.subscriptionGroupID ?? self.id
    }
    
    //MARK: Equatable Methods
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
    
    public static func == (lhs: SubscriptionGroup, rhs: SubscriptionGroup) -> Bool {
        return lhs.id == rhs.id
    }
    
    public init(id: String, products: Set<Product>) {
        self.id = id
        self.products = products
    }
    
    public func product(for productId: String)->Product? {
        return products.first { product in
            return product.id == productId
        }
    }
    
    public func currentProduct(renewal: Product.SubscriptionInfo.RenewalInfo)->Product? {
        return product(for: renewal.currentProductID)
    }
    
    public func renewingProduct(renewal: Product.SubscriptionInfo.RenewalInfo)->Product? {
        guard let nextproductId = renewal.autoRenewPreference else {
            return nil
        }
        return product(for: nextproductId)
    }
}




