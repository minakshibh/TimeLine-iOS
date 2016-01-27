//
//  TimelineDeleteableBehavior.swift
//  Timeline
//
//  Created by Valentin Knabel on 10.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import ConclurerHook

protocol DeleteableBehavior { }

extension DeleteableBehavior where Self: UIViewController, Self: Reloadable {
    func confirmDeleteableBehavior(timeline: Timeline)(action: UIAlertAction) {
        let confirmation = UIAlertController(title: local(.TimelineAlertDeleteConfirmTitle), message: local(.TimelineAlertDeleteConfirmMessage), preferredStyle: .Alert)
        confirmation.addAction(title: local(.TimelineAlertDeleteConfirmActionDelete), style: .Destructive, handler: performDeleteableBehaviorAction(timeline))
        confirmation.addAction(title: local(.TimelineAlertDeleteConfirmActionCancel), style: .Cancel, handler: nil)
        presentAlertController(confirmation)
    }

    func performDeleteableBehaviorAction(timeline: Timeline)(action: UIAlertAction) {
        let alert = UIAlertController(title: LocalizedString.TimelineAlertDeleteWaitTitle.localized, message: local(.TimelineAlertDeleteWaitMessage), preferredStyle: .Alert)
        presentAlertController(alert)

        timeline.delete { (error) -> () in
            alert.dismissViewControllerAnimated(true) {
                if let error = error {
                    let alert = UIAlertController(title: local(.TimelineAlertDeleteErrorTitle), message: error, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: local(.TimelineAlertDeleteErrorActionDismiss), style: .Default, handler: nil))
                    self.presentAlertController(alert)
                    return
                }

                for i in 0..<(Storage.session.currentUser?.timelines.count ?? 0) {
                    let t = Storage.session.currentUser!.timelines[i]
                    if timeline.state.uuid == t.state.uuid {
                        Storage.session.currentUser!.timelines.removeAtIndex(i)
                        serialHook.perform(key: .ForceReloadData, argument: ())
                        break
                    }
                }
            }
        }
    }
}
