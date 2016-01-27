//
//  ShareableBehavior.swift
//  Timeline
//
//  Created by Valentin Knabel on 10.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import UIKit

protocol ShareableBehavior { }

extension ShareableBehavior where Self: UIViewController {
    func performShareableBehaviorAction(timeline: Timeline)(action: UIAlertAction) {
        let controller = UIActivityViewController(activityItems: timeline.sharingActivities, applicationActivities: nil)
        presentActivityViewController(controller)
    }

    func performShareableBehaviorAction(user: User)(action: UIAlertAction) {
        let controller = UIActivityViewController(activityItems: user.sharingActivities, applicationActivities: nil)
        presentActivityViewController(controller)
    }
}
