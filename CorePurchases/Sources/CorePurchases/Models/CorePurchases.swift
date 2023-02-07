import StoreKit
//import StoreKitTest
import SwiftUI

public enum StoreError: Error {
    case failedVerification
}

public enum FetchState<Element> {
    
    case idle
    case fetching
    case fetched(results: [Element])
    case failed(error: Error)
    
    func fetched()->Bool {
        switch self {
        case .fetched:
            return true
        default: return false
        }
    }
    
    func results()->[Element] {
        switch self {
        case .fetched(let results):
            return results
        default: return []
        }
    }
}

public class Store: ObservableObject {
    
    public enum ProductTransaction {
        
        case idle
        case purchasing(product: Product)
        case pending(purchase: Product)
        case canceled(purchase: Product)
        case failed(purchase: Product, error: Error)
        
        var processing:Bool {
            switch self {
            case .purchasing: return true
            default: return false
            }
        }
    }
    
    let identifiers:Set<String>
        
    @Published public var activeTransaction:ProductTransaction = .idle
    @Published public var store:FetchState<Product> = .idle
    @Published public var entitlements:FetchState<StoreKit.Transaction> = .idle
    @Published public var consumablePurchases:[String : Int] = .init()
    
    var products:[Product] { return store.results() }
    
    private var updateListenerTask: Task<Void, Error>? = nil
    
    private let cache:PurchasesCache = .init()
    
    public init(identifiers:[String]) {
        
        self.identifiers = Set(identifiers.map { $0 })
        updateListenerTask = listenForTransactions()
        
        Task {
            await fetchProducts()
            await fetchEntitlements()
            await syncEntitlementCache()
        }
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        
        return Task.detached {
            //Iterate through any transactions that don't come from a direct call to `purchase()`.
            
            for await result in Transaction.updates {
                do {
                    
                    let transaction = try self.checkVerified(result)
                    await transaction.finish()
               
                    print("listener recieved Transaction: ", transaction)
                    if let revokeReason = transaction.revocationReason {
                        
                        let validTransactions:[StoreKit.Transaction] = self.entitlements.results().filter { trans in
                            return trans.productID != transaction.productID
                        }
                        
                        self.cache.close(product: transaction.productID)
                        await self.setEntitlements(state: .fetched(results: validTransactions))
                    }
                } catch {
                    //StoreKit has a transaction that fails verification. Don't deliver content to the user.
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    private func handleRevoke(productId: String) {
        
    }
    private func setActiveTransaction(action: ProductTransaction) async {
        await MainActor.run {
            self.activeTransaction = action
        }
    }
    private func setStoreState(state: FetchState<Product>) async {
        await MainActor.run {
            self.store = state
        }
    }
    
    private func setEntitlements(state: FetchState<StoreKit.Transaction>) async {
        await MainActor.run {
            self.entitlements = state
        }
    }
    
    func fetchProducts() async {
        
        await setStoreState(state: .fetching)
        do {
            let products:[Product] = try await Product.products(for: identifiers)
            await setStoreState(state: .fetched(results: products))

        } catch {
            await setStoreState(state: .failed(error: error))
        }
    }
    
    func fetchEntitlements() async {
    
        await setEntitlements(state: .fetching)
        var verified:[StoreKit.Transaction] = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                verified.append(transaction)
            } catch {
                await setEntitlements(state: .failed(error: error))
                return
            }
        }
                
        await setEntitlements(state: .fetched(results: verified))
    }
    
    func syncEntitlementCache() async {
        guard entitlements.fetched() && store.fetched() else
        {
            return
        }
        
        let verified:[StoreKit.Transaction] = entitlements.results()
        
        func isVerified(product: Product)->Bool {
            return verified.contains { transaction in
                return product.id == transaction.productID
            }
        }
        
        func getTransaction(product: Product)->StoreKit.Transaction? {
            return verified.first { transaction in
                return transaction.productID == product.id
            }
        }
        
        let nonconsumables:[Product] = store.results().filter { product in
            return product.type != .consumable
        }
        
        nonconsumables.forEach { product in
            if let transaction = getTransaction(product: product) {
                cache(product: product, with: transaction)
            } else {
                cache.close(product: product.id)
            }
        }
        
        let consumables:[Product] = store.results().filter { product in
            return product.type == .consumable
        }
        
        await MainActor.run {
            for consumable in consumables {
                consumablePurchases[consumable.id] = cache.consumables(for: consumable.id)
            }
        }
    }
    
    func cache(product: Product, with entitlement: StoreKit.Transaction) {
        switch product.type {
        case .autoRenewable:
            cache.markPurchased(product: product.id)
        break
        case .nonConsumable:
            cache.markPurchased(product: product.id)
        break
        case .consumable:
            //we will need some way of customizing this.
            //Consumables are not returned in Transaction.Entitlements
        break
        case .nonRenewable:
            cache.markPurchased(product: product.id)
        break
        default: break
        }
    }
    
    @discardableResult func buy(product: Product) async -> Product.PurchaseResult? {
       
        await setActiveTransaction(action: .purchasing(product: product))
        
        do {
            
            let result:Product.PurchaseResult = try await product.purchase()

            switch result {
            case .success(let verification):
                
                let transaction = try checkVerified(verification)
                await transaction.finish()
                cache(product: product, with: transaction)
                await setActiveTransaction(action: .idle)
                print("adding transaction: ", transaction)
                await setEntitlements(state: .fetched(results: entitlements.results() + [transaction]))
            break
            case .userCancelled:
                await setActiveTransaction(action: .canceled(purchase: product))
            break
            case .pending:
                await setActiveTransaction(action: .pending(purchase: product))
            break
            default: break
            }
            
            return result
            
        } catch {
            await setActiveTransaction(action: .failed(purchase: product, error: error))
        }
        return nil
    }

    func buy(consumable: Product, quantity: Int) async {
        guard consumable.type == .consumable else {
            print("Not a consumable!")
            return
        }
        guard let result = await buy(product: consumable) else {
            return
        }
        switch result {
        case .success:
            print("buying consumable: ", consumable.id)
            
            await cache.increment(consumableId: consumable.id, quantity: quantity)
            
            await MainActor.run {
                self.consumablePurchases[consumable.id] = cache.consumables(for: consumable.id)
            }
        break
        default: break
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
}


//Helpers
extension Store {
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        //Check whether the JWS passes StoreKit verification.
        
        switch result {
        case .unverified:
            //StoreKit parses the JWS, but it fails verification.
            throw StoreError.failedVerification
        case .verified(let safe):
            //The result is verified. Return the unwrapped value.
            return safe
        }
    }
    
    func sortByPrice(_ products: [Product]) -> [Product] {
        products.sorted(by: { return $0.price < $1.price })
    }
    
    public func inEntitlements(product: Product)->Bool {
        return entitlements.results().contains { transaction in
            return product.id == transaction.productID
        }
    }
    
    public func isCached(product: Product)->Bool {
        return cache.isPurchased(product: product.id)
    }
    
    func removePurchase(product: Product) {
        cache.close(product: product.id)
    }
    
    func cachePurchase(product: Product) {
        cache.markPurchased(product: product.id)
    }

    func cacheValidTransactions(purchases: [Product]) {
        clearPurchases()
        for product in purchases {
            cache.markPurchased(product: product.id)
        }
    }
    
    func clearPurchases() {
        cache.closeAll(identifiers: Array(identifiers))
    }
}

extension Store {
    
    public func entitlement(for product: Product)->StoreKit.Transaction? {
        return entitlements.results().first(where: { transaction in
            return transaction.productID == product.id
        })
    }

    //search entitlements first, then fallback on the cache
    public func isNonConsumableOpen(productId: String)->Bool {
        
        guard let product = store.results().first(where: { product in
            return product.id == productId
        }) else {
            return cache.isPurchased(product: productId)
        }
        
        guard product.type == .nonConsumable else { return false }
        
        if entitlements.results().contains(where: { transaction in
            return transaction.productID == productId
        }) {
            return true
        }
        return cache.isPurchased(product: productId)
    }
    
    public func isSubscriptionOpen(productId: String)->Bool {
        if entitlements.results().contains(where: { transaction in
            return transaction.productID == productId
        }) {
            return true
        }
        return cache.isPurchased(product: productId)
    }
    
    @MainActor public func consumableAvailable(productId: String)-> Int {
        
        return cache.consumables(for: productId)
    }
    
    public func consumables()->[Product] {
        return products.filter { product in
            product.type == .consumable
        }
    }
    
    public func nonConsumables()->[Product] {
        return products.filter { product in
            return product.type == .nonConsumable
        }
    }
    
    public func nonRenewingSubscriptions()->[Product] {
        return products.filter { product in
            return product.type == .nonRenewable
        }
    }
    
    public func renewingSubscriptions()->[Product] {
        return products.filter { product in
            return product.type == .autoRenewable
        }
    }
    
    func subscriptionGroupsDictionary()->[String : Set<Product>] {
        
        var dict:[String: Set<Product>] = .init()

        for subscription in renewingSubscriptions(){
            
            guard let groupId:String = subscription.subscription?.subscriptionGroupID else {
                continue
            }
            
            if dict[groupId] != nil {
                dict[groupId]?.insert(subscription)
            } else {
                dict[groupId] = Set<Product>([subscription])
            }
        }
        return dict
    }
    
    public func subscriptionGroups()->[SubscriptionGroup] {
        var groups:[SubscriptionGroup] = []
        for (groupId, productSet) in subscriptionGroupsDictionary() {
            groups.append(SubscriptionGroup(id: groupId, products: productSet))
        }
        return groups
    }
}
