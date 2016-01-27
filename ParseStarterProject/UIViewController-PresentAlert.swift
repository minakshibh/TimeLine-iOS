//
//  UIViewController-PresentAlert.swift
//  Timeline
//
//  Created by Valentin Knabel on 10.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import UIKit

extension UIViewController {
    /// This is a fix-method for iOS9
    @available(*, message="Fix method for iOS9")
    func presentTintedViewController(controller: UIViewController, animated: Bool = true, completion: (() -> ())? = nil) {
        let tintColor = view.tintColor
        controller.view.tintColor = tintColor
        presentViewController(controller, animated: animated) {
            completion?()
            controller.view.tintColor = tintColor
        }
        controller.view.tintColor = tintColor
    }
    func presentAlertController(controller: UIAlertController, animated: Bool = true, completion: (() -> ())? = nil) {
        presentTintedViewController(controller, animated: animated, completion: completion)
    }
    func presentActivityViewController(controller: UIActivityViewController, animated: Bool = true, completion: (() -> ())? = nil) {
        presentTintedViewController(controller, animated: animated, completion: completion)
    }
}
