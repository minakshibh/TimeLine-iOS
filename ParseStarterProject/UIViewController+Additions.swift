//
//  UIViewController+Additions.swift
//  Timeline
//
//  Created by Valentin Knabel on 31.07.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    @IBAction public func dismissViewControllerWithAnimation(sender: AnyObject?) {
        dismissViewControllerAnimated(true, completion: { })
    }
    
    @IBAction public func dismissViewControllerWithoutAnimation(sender: AnyObject?) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
}
