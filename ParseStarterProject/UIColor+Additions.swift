//
//  UIColor+Additions.swift
//  Timeline
//
//  Created by Valentin Knabel on 14.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func topBarTintColor() -> UIColor {
        return UIColor(red: 255/255.0, green: 148/255.0, blue: 1/255.0, alpha: 1.0)
    }
    
    static func barButtonTintColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
    static func bottomBarTintColor() -> UIColor {
        return UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1.0)
    }
    
    static func tintColor() -> UIColor {
        return UIColor(red: 255/255.0, green: 148/255.0, blue: 1/255.0, alpha: 1.0)
    }
    
    // Creates a UIColor from a Hex string.
    static func from(hexString hex: String?) -> UIColor? {
        if let hex = hex {
        var cString: NSString = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(1)
        }
        
        if cString.length != 6 {
            return UIColor.grayColor()
        }
        
        let rString: NSString = cString.substringToIndex(2)
        let gString: NSString = (cString.substringFromIndex(2) as NSString).substringToIndex(2)
        let bString: NSString = (cString.substringFromIndex(4) as NSString).substringToIndex(2)
        
        var r: CUnsignedInt = 0, g: CUnsignedInt = 0, b: CUnsignedInt = 0
        NSScanner(string: rString as String).scanHexInt(&r)
        NSScanner(string: gString as String).scanHexInt(&g)
        NSScanner(string: bString as String).scanHexInt(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
        } else {
            return nil 
        }
    }
    
    var hexString: String {
        let components = CGColorGetComponents(self.CGColor);
            let r = components[0]
            let g = components[1]
            let b = components[2]
            let hexString = NSString(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
            return hexString as String
    }
    
}
