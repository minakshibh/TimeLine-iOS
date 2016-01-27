//
//  ActiveControllerBehavior.swift
//  Timeline
//
//  Created by Valentin Knabel on 13.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import ConclurerHook

extension HookKey {
    static var ActiveViewController: HookKey<String, (), UIViewController> {
        return HookKey<String, (), UIViewController>(rawValue: "\(__FILE__):HookKey.ActiveViewController")
    }
}

func activeController() -> UIViewController? {
    return Array(serialHook.perform(key: .ActiveViewController, argument: ())).last
}

protocol ActiveControllerBehavior { }
extension UIViewController: ActiveControllerBehavior {
    func setUpActiveControllerBehavior() -> AnyObject? {
        return serialHook.add(key: .ActiveViewController) {
            return self as UIViewController
        }
    }
}