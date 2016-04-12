//
//  UserMoreButtonBehavior.swift
//  Timeline
//
//  Created by Valentin Knabel on 11.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import ConclurerHook

extension HookKey {
    static var UserMoreButtonTapped: HookKey<String, User, Void> {
        return HookKey<String, User, Void>(rawValue: "UserSummaryView.UserMoreButtonTapped")
    }
}

protocol UserMoreButtonBehavior: Hooking { }

extension UserMoreButtonBehavior where Self: UIViewController, Self: Reloadable, Self: PushableBehavior, Self: ShareableBehavior, Self: BlockableBehavior {

    func setUpUserMoreButtonBehavior() -> AnyObject? {
        return serialHook.add(key: .UserMoreButtonTapped, closure: triggerMoreButtonBehavior)
    }

    func triggerMoreButtonBehavior(user: User) {
        let sheet = UIAlertController(title: lformat(.UserSheetMoreButtonTitle1s, user.name), message: local(.UserSheetMoreButtonMessage), preferredStyle: .ActionSheet)
        sheet.addAction(title: local(.UserSheetMoreButtonCancel), style: .Cancel, handler: nil)
        sheet.addAction(title: local(.UserSheetMoreButtonShare), style: .Default, handler: performShareableBehaviorAction(user))
        
        // Commented show follower and show like functionality for user more button
//        sheet.addAction(title: local(.UserSheetMoreButtonFollowers), style: .Default) { _ in
//            self.performSegueWithIdentifier("ShowUserList", sender: FollowableValue(followable: user))
//        }
//        sheet.addAction(title: local(.UserSheetMoreButtonLikers), style: .Default) { _ in
//            self.performSegueWithIdentifier("ShowUserList", sender: LikeableValue(likeable: user))
//        }

        if user.uuid != Storage.session.currentUser?.uuid {
            sheet.addAction(title: local(user.blocked ? .UserSheetMoreButtonUnblock: .UserSheetMoreButtonBlock), style: .Destructive, handler: confirmBlockableBehavior(user))
        }
        self.presentAlertController(sheet)
    }
    
}
