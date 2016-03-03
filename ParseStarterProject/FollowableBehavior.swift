//
//  FollowableBehavior.swift
//  Timeline
//
//  Created by Valentin Knabel on 07.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import SWFrameButton

protocol FollowableBehavior {
    typealias TargetBehaviorType: Followable
    var behaviorTarget: TargetBehaviorType? { get }
    var followButton: SWFrameButton! { get }
}

private extension UIColor {
    static var followableTintColor: UIColor! {
        return UIColor.from(hexString: "FF9A00")
    }
}

extension FollowableBehavior where TargetBehaviorType: Ownable {

    func refreshFollowableBehavior() {
        followButton.cornerRadius =!= 7
//        followButton.tintColor =!= .followableTintColor
        followButton.normalImage =!= UIImage(assetIdentifier: .FollowableButton)
        followButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 0)
        followButton.setNeedsLayout()
        
        if let target = behaviorTarget {
            followButton.setTitle("\(target.followersCount)", forState: .Normal)
            followButton.selected =!= target.followed != .NotFollowing && !target.isOwn
            followButton.enabled =!= true
            followButton.borderWidth =!= target.isOwn ? 0 : 1.5
            followButton.tintColor =!= target.isOwn ? UIColor.blackColor() : .followableTintColor

        } else {
            followButton.enabled =!= false
            followButton.selected =!= false
            followButton.normalTitle =!= "0"
            followButton.borderWidth =!= 1.5
        }
    }

    func toggleFollowState() {
        if let target = behaviorTarget where !target.isOwn {
            target.toggleFollowState {
                self.refreshFollowableBehavior()
            }
            refreshFollowableBehavior()
        } else if let likeable = behaviorTarget as? Followable {
            guard let controller = activeController() else { return }
            controller.performSegueWithIdentifier("ShowUserList", sender: FollowableValue(followable: likeable))
        }
    }
    
}
