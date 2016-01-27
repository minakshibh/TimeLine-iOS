//
//  Session+InAppPurchase.swift
//  Timeline
//
//  Created by Valentin Knabel on 01.09.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import Foundation
import RMStore

extension String {
    
    static let additionalTimelineProduct = "Additional_Timeline"
    
}

extension Set {
    
    static func productsSet() -> Set<NSString> {
        return Set<String>([String.additionalTimelineProduct])
    }
    
}

extension Session {
    
    func requestProducts(valid validPurchases: ([SKProduct]) -> Void) {
        RMStore.defaultStore().requestProducts(Set<NSString>.productsSet(), success: { valids, invalids in
            validPurchases(valids as? [SKProduct] ?? [])
            }, failure: { error in
                print("failed product fetch: \(error)")
                validPurchases([])
        })
    }
    
    func payProduct(product: String, success: () -> Void, failure: (String?) -> Void) {
        RMStore.defaultStore().addPayment(product, success: { transaction in
            switch product {
            case String.additionalTimelineProduct:
                main {
                    self.unsyncedTimelineIncrement++
                    
                    self.updateProduct(product, success: success, failure: failure)
                    Storage.save()
                }
                
            default:
                assertionFailure("Unknown product")
                break
            }
            }, failure: { transaction, error in
                failure(error.localizedDescription)
        })
    }
    
    func updateProduct(product: String, success: () -> Void, failure: (String?) -> Void) {
        main {
            if self.unsyncedTimelineIncrement - self.activeTimelineIncrementSyncs > 0 {
                self.activeTimelineIncrementSyncs++
                Storage.performRequest(.IncrementTimelineMax, completion: { (json) -> Void in
                    if let count = json["success"] as? Int {
                        self.allowedTimelinesCount = count
                        self.unsyncedTimelineIncrement--
                        self.activeTimelineIncrementSyncs--
                        
                        self.updateProduct(product, success: success, failure: failure)
                        
                        Storage.save()
                    } else {
                        failure(nil)
                    }
                })
                
            } else {
                success()
            }
        }
    }
    
}
