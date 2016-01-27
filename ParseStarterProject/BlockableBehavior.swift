//
//  BlockableBehavior.swift
//  Timeline
//
//  Created by Valentin Knabel on 10.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import UIKit

protocol BlockableBehavior { }

extension BlockableBehavior where Self: UIViewController {
    func confirmBlockableBehavior<B: Blockable where B: Named>(blockable: B)(action: UIAlertAction) {
        let alert = UIAlertController(
            title: local(!blockable.isBlocked ? LocalizedString.TimelineAlertBlockTitle : LocalizedString.TimelineAlertUnblockTitle),
            message: lformat(!blockable.isBlocked ? LocalizedString.TimelineAlertBlockMessage1s : LocalizedString.TimelineAlertUnblockMessage1s, args: blockable.name ?? ""),
            preferredStyle: .Alert
        )
        alert.addAction(
            title: local(!blockable.isBlocked ? LocalizedString.TimelineAlertBlockActionCancel : LocalizedString.TimelineAlertUnblockActionCancel),
            style: .Cancel,
            handler: nil
        )
        alert.addAction(
            title: local(!blockable.isBlocked ? LocalizedString.TimelineAlertBlockActionBlock : LocalizedString.TimelineAlertUnblockActionUnblock),
            style: .Destructive,
            handler: performBlockableBehaviorAction(blockable)
        )
        presentAlertController(alert)
    }

    func performBlockableBehaviorAction<B: Blockable where B: Named>(blockable: B)(action: UIAlertAction) {
        let handler = !blockable.isBlocked ? blockable.block : blockable.unblock
        handler {
            // TODO: Possibly do something
        }
    }
}
