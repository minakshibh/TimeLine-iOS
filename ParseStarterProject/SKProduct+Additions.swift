//
//  SKProduct+Additions.swift
//  Timeline
//
//  Created by Valentin Knabel on 01.09.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import StoreKit

public extension SKProduct {
    
    var localizedPrice: String! {
        let formatter = NSNumberFormatter()
        formatter.formatterBehavior = .Behavior10_4
        formatter.numberStyle = .CurrencyStyle
        formatter.locale = priceLocale
        
        let str = formatter.stringFromNumber(price)
        return str
    }
    
}
