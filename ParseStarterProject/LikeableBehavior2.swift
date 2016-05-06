//
//  LikeableBehavior.swift
//  Timeline
//
//  Created by Valentin Knabel on 07.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import SWFrameButton

protocol LikeableBehavior2 {
    typealias TargetBehaviorType: Followable
    var behaviorTarget: TargetBehaviorType? { get }
    var updatedFollowButton: SWFrameButton! { get }
    var btnWebsite: SWFrameButton! { get }
}

private extension UIColor {
    static var likeableTintColor: UIColor! {
        return UIColor.from(hexString: "0A256C")
    }
}

extension LikeableBehavior2 where TargetBehaviorType: Ownable {

    func refreshLikeableBehavior2() {
//        likeButton1.cornerRadius =!= 7
//        likeButton.tintColor =!= .likeableTintColor
        updatedFollowButton.normalImage =!= UIImage(assetIdentifier: .likeImage)
//        likeButton1.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 0)

//        likeButton1.setNeedsLayout()

        if let behaviorTarget = behaviorTarget {
//            likeButton1.setTitle("\(behaviorTarget.likesCount)", forState: .Normal)
           // print("****\(behaviorTarget.liked) 0-----\(behaviorTarget.isOwn)")
//            likeButton1.selected =!= behaviorTarget.liked
            updatedFollowButton.enabled =!= true
            updatedFollowButton.selected = false
            updatedFollowButton.borderWidth = 0
//            likeButton1.borderWidth =!= behaviorTarget.isOwn ? 0 : 1.5
//            likeButton1.tintColor =!= behaviorTarget.isOwn ? UIColor.blackColor() : .likeableTintColor
            //print("\(behaviorTarget.followed)")
            updatedFollowButton.normalImage =!= behaviorTarget.followed != .NotFollowing ? UIImage(named: "dislikeImage") : UIImage(named: "likeImage")
            
//            followTimelineButton.normalImage =!= target.followed != .NotFollowing ? UIImage(assetIdentifier: .dislikeImage) : UIImage(assetIdentifier: .likeImage)
        } else {
            updatedFollowButton.enabled =!= false
            updatedFollowButton.selected =!= false
            updatedFollowButton.normalTitle =!= "0"
//            likeButton1.borderWidth =!= 1.5
        }
        
        
        if PFUser.currentUser()?.authenticated ?? false {
            let user = PFUser.currentUser()!
            
            let isFacebook = NSUserDefaults.standardUserDefaults().valueForKey("facebook_login")
            if(isFacebook != nil)
            {
            }else{
                var websiteStr:String = ""
                if user["website"] != nil {
                    websiteStr = "\(user.objectForKey("website")!)"
                    btnWebsite.setTitle(websiteStr, forState: .Normal)
                }
                if user["website"] == nil {
                    websiteStr = ""
                }
                
                
            }
        }
    }

    func toggleLiked2() {
        if let target = behaviorTarget where !target.isOwn {
        target.toggleFollowState {
            
            self.refreshLikeableBehavior2()
        }
            refreshLikeableBehavior2()
        } else if let likeable = behaviorTarget as? Likeable {
            guard let controller = activeController() else { return }
            controller.performSegueWithIdentifier("ShowUserList", sender: LikeableValue(likeable: likeable))
        }
    }
    
}
