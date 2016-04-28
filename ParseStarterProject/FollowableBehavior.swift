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
    var followTimelineButton: UIButton! { get }
    
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
            followButton.enabled =!= true
            followButton.borderWidth =!= 0
            followButton.tintColor =!= UIColor.blackColor()
            if (followTimelineButton != nil)
            {
                followTimelineButton.hidden =!= target.isOwn ? true : false
                followTimelineButton.selected =!= target.followed != .NotFollowing && !target.isOwn
                followTimelineButton.enabled =!= true
                followTimelineButton.normalImage =!= target.followed != .NotFollowing ? UIImage(assetIdentifier: .dislikeImage) : UIImage(assetIdentifier: .likeImage)
            }
           
        } else {
            followButton.enabled =!= false
            followButton.selected =!= false
            followButton.normalTitle =!= "0"
            followButton.borderWidth =!= 0
            if (followTimelineButton != nil)
            {
                followTimelineButton.selected =!= false
                followTimelineButton.enabled =!= false
            }
        }
    }

    func toggleFollowState() {
        if let target = behaviorTarget where !target.isOwn {
            if let likeable = behaviorTarget as? Followable {
                guard let controller = activeController() else { return }
                controller.performSegueWithIdentifier("ShowUserList", sender: FollowableValue(followable: likeable))
            }
                return
        }
        
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
    
    func toggleFollowUser() {
        if let target = behaviorTarget where !target.isOwn {
            target.toggleFollowState {
                self.refreshFollowableBehavior()
            }
            refreshFollowableBehavior()
        }
    }
    
    func toggleFollowedState() {
        if let target = behaviorTarget {
            target.toggleFollowState {
                self.refreshFollowableBehavior()
            }
            refreshFollowableBehavior()
        }
    }
    func showFollowers() {
        if let likeable = behaviorTarget as? Followable {
            guard let controller = activeController() else { return }
            controller.performSegueWithIdentifier("ShowUserList", sender: FollowableValue(followable: likeable))
        }
    }
    func showCommentScreen(timelineID : String , ownTimeline: Bool){
        guard let controller = activeController() else { return }
        let vc = CommentViewController()
        vc.ownTimeline = ownTimeline
        vc.timelineCommentID = timelineID
        controller.navigationController?.pushViewController(vc, animated: true)
    }
}
