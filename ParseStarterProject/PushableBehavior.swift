//
//  PushableBehavior.swift
//  Timeline
//
//  Created by Valentin Knabel on 10.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import ConclurerHook

extension HookKey {
    static var TriggerPushable: HookKey<String, Pushable, ()> {
        return HookKey<String, Pushable, ()>(rawValue: "PushableBehavior.TriggerPushable")
    }
}

protocol PushableBehavior: Hooking { }
extension PushableBehavior where Self: UIViewController {
    func performPushableBehaviorAction(pushable: Pushable, identifier: String) {
        performSegueWithIdentifier(identifier, sender: pushable)
    }
    func performPushableBehaviorAction(pushable: Pushable, identifier: String)(action: UIAlertAction) {
        performSegueWithIdentifier(identifier, sender: pushable)
    }

    func performPushableBehaviorAction(pushable: Pushable) {
        performSegueWithIdentifier(pushable.pushIdentifier, sender: pushable)
    }
    func performPushableBehaviorAction(pushable: Pushable)(action: UIAlertAction) {
        performSegueWithIdentifier(pushable.pushIdentifier, sender: pushable)
    }

    func setUpPushableBehavior() -> AnyObject? {
        return serialHook.add(key: .TriggerPushable) { pushable in
            self.performPushableBehaviorAction(pushable)
        }
    }
}
