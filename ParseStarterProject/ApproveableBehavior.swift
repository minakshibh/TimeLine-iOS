//
//  ApproveableBehavior.swift
//  Timeline
//
//  Created by Valentin Knabel on 13.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import SWFrameButton

protocol ApproveableBehavior {
    typealias TargetBehaviorType: Approveable
    var behaviorTarget: TargetBehaviorType? { get }
    var approveButton: SWFrameButton! { get }
    var approveConstraint: NSLayoutConstraint! { get }
    var hidesApproveButton: Bool { get }
}

private extension UIColor {
    static var approveableTintColor: UIColor! {
        return UIColor.from(hexString: "FF0000")
    }
}

extension ApproveableBehavior where TargetBehaviorType: Named {

    func refreshApproveableBehavior() {
        main {
//            self.approveButton.cornerRadius =!= 7
            self.approveButton.tintColor =!= .approveableTintColor
            self.approveButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 0)

            self.approveButton.setTitle(local(.UserButtonRespondTitle), forState: .Normal)
            self.approveButton.enabled =!= true
            self.approveButton.borderWidth =!= 1.5
//            self.approveButton.layer.borderColor = UIColor.blackColor().CGColor
//            self.approveButton.titleLabel?.numberOfLines = 1
//            self.approveButton.titleLabel?.adjustsFontSizeToFitWidth = true
//            self.approveButton.titleLabel?.lineBreakMode = .ByClipping
            self.approveButton.hidden = self.hidesApproveButton
//            self.approveConstraint.active = !self.hidesApproveButton

            self.approveButton.setNeedsLayout()
        }
    }

    func triggerApproveableBehavior() {
        
//        self.approveButton.backgroundColor = UIColor.redColor()
//        self.approveButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        guard let approveable = behaviorTarget,
            let controller = activeController()
            else { return }

        func removeData() {
            Storage.session.currentUserPendingCache = Storage.session.currentUserPendingCache.filter {
                $0 != (approveable as? User)?.uuid
            }
        }
        func reloadData() {
            guard let reloadable = controller as? Reloadable else { return }
            reloadable.reloadData()
        }

        let title = lformat(.UserSheetRespondTitle1s, behaviorTarget?.fullName ?? local(.UserButtonRespondTitle))
        let alert = UIAlertController(title: title, message: local(.UserSheetRespondMessage), preferredStyle: .ActionSheet)
        alert.addAction(title: local(.UserSheetRespondApprove), style: .Default) { _ in
            approveable.approve(reloadData)
            self.resetPendingFollowerCount()
            removeData()
            self.approveButton.backgroundColor = UIColor.whiteColor()
            self.approveButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        }
        alert.addAction(title: local(.UserSheetRespondDecline), style: .Destructive) { _ in
            approveable.decline(reloadData)
            self.resetPendingFollowerCount()
            removeData()
            self.approveButton.backgroundColor = UIColor.whiteColor()
            self.approveButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        }
        alert.addAction(title: local(.UserSheetRespondCancel), style: .Cancel){ _ in
//            self.approveButton.layer.borderColor = UIColor.blackColor().CGColor
            self.approveButton.backgroundColor = UIColor.whiteColor()
            self.approveButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        }

        controller.presentAlertController(alert)
    }
    
    func resetPendingFollowerCount() {
        if let user = Storage.session.currentUser {
            if user.pendingFollowersCount > 0 {
                Storage.session.currentUser?.pendingFollowersCount=user.pendingFollowersCount!-1
            }
        }
    }
    

    
}
