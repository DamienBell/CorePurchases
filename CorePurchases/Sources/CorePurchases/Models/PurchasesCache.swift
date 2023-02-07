//
//  File.swift
//  
//
//  Created by Damien Bell on 1/30/23.
//

import Foundation

public struct PurchasesCache {
    
    //pass one ore more product id's for a non-consumbable purchase
    //True if any of the purchases are true
    //Passing more than one product is often needed for tiered purchases where more than one purchase can be true

    public init(){}
    
    public func isPurchased(products:[String])->Bool {
        for product in products {
            if self.isPurchased(product: product) {
                return true
            }
        }
        return false
    }
    
    public func isPurchased(product: String)->Bool {
        return UserDefaults.standard.bool(forKey: product) == true
    }
    
    public func markPurchased(product: String) {
        UserDefaults.standard.set(true, forKey: product)
        UserDefaults.standard.synchronize()
    }
    
    public func close(product: String) {
        UserDefaults.standard.set(false, forKey: product)
        UserDefaults.standard.synchronize()
    }
    
    @MainActor public func increment(consumableId: String, quantity: Int) {
        let current:Int = consumables(for: consumableId)
        setConsumable(consumableId: consumableId, quantity: current + quantity)
        print("incremented from: \(current) to \(current + quantity)")
    }
    
    @MainActor public func decrement(consumableId: String, quantity: Int) {
        let current:Int = consumables(for: consumableId)
        let value:Int = (current - quantity >= 0) ? current - quantity : 0
        setConsumable(consumableId: consumableId, quantity: value)
    }
    
    @MainActor public func setConsumable(consumableId: String, quantity: Int) {
        UserDefaults.standard.setValue(quantity, forKey: consumableId)
        let success = UserDefaults.standard.synchronize()
        print("wrote consumable: ", success, quantity, consumableId)
    }
    
    @MainActor public func consumables(for productId: String)->Int {
        return UserDefaults.standard.integer(forKey: productId)
    }
    
    public func closeAll(identifiers: [String]) {
        for product in identifiers {
            close(product: product)
        }
    }
}
