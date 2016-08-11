//
//  FollowableBehavior.swift
//  Timeline
//
//  Created by Valentin Knabel on 07.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import SWFrameButton

protocol FollowableBehaviorCount {
    typealias TargetBehaviorType: Followable
    var behaviorTarget: TargetBehaviorType? { get }
//    var followButton: SWFrameButton! { get }
    var followTimelineButton: UIButton! { get }
    var updatedFollowButton : SWFrameButton! {get}
    var imagePerson: UIImageView! { get }

}

private extension UIColor {
    static var followableTintColor: UIColor! {
        return UIColor.from(hexString: "FF9A00")
    }
}

extension FollowableBehaviorCount where TargetBehaviorType: Ownable {

    func refreshFollowableBehaviorCount() {
//        followButton.cornerRadius =!= 7
////        followButton.tintColor =!= .followableTintColor
//        followButton.normalImage =!= UIImage(assetIdentifier: .FollowableButton)
//        followButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 0)
//        followButton.setNeedsLayout()
        
        if let target = behaviorTarget {
            //followButton.setTitle("\(target.followersCount)", forState: .Normal)
            
            // commented on 31 May.
//            if(target.followersCount > 0){
//                if("\(target.followed)" == "Following"){
//                    
//                    imagePerson.image = UIImage(named: "likeImage.png")
//                }
//
//                //updatedFollowButton.setTitle("testing", forState: .Normal)
//            }else{
//                imagePerson.image = UIImage(named: "dislikeImage.png")
//               
//                //updatedFollowButton.setTitle("Follow", forState: .Normal)
//            }
            
            if target.isOwn{
                if(target.followersCount > 0){
                    imagePerson.image = UIImage(named: "likeImage.png")
                    updatedFollowButton.setTitle("You", forState: .Normal)
                }else{
                    imagePerson.image = UIImage(named: "dislikeImage.png")
                    
                }
            }else{
                if  !target.isOwn {
                    print(" follow status: \(target.followed)")
                    var status = false
                    if ("\(target.followed)" == "Following" ){
                        status = true
                        updatedFollowButton.setTitle("Unfollow", forState: .Normal)
                        updatedFollowButton.setTitleColor(UIColor.from(hexString: "3d89c9"), forState: .Normal)
                        imagePerson.image =!= UIImage(named: "dislikeImage.png")
                        
                    }else if ("\(target.followed)" == "NotFollowing"){
                        status = false
                        updatedFollowButton.setTitle("Follow", forState: .Normal)
                        updatedFollowButton.setTitleColor(UIColor.from(hexString: "e7e7e7"), forState: .Normal)
                        imagePerson.image =!= UIImage(named: "likeImage.png")
                    }else{
                        status = false
                        updatedFollowButton.setTitle("Pending", forState: .Normal)
                        updatedFollowButton.setTitleColor(UIColor.from(hexString: "e7e7e7"), forState: .Normal)
                        imagePerson.image =!= UIImage(named: "likeImage.png")
                    }
                    
                    
                }

            }
           // print("\(target.followed)")
//            followButton.enabled =!= true
//            followButton.borderWidth =!= 0
//            followButton.tintColor =!= UIColor.blackColor()
//            if (followTimelineButton != nil)
//            {
//                followTimelineButton.hidden =!= target.isOwn ? true : false
//                followTimelineButton.selected =!= target.followed != .NotFollowing && !target.isOwn
//                followTimelineButton.enabled =!= true
//                followTimelineButton.normalImage =!= target.followed != .NotFollowing ? UIImage(assetIdentifier: .dislikeImage) : UIImage(assetIdentifier: .likeImage)
//            }
           
        } else {
//            followButton.enabled =!= false
//            followButton.selected =!= false
//            followButton.normalTitle =!= "0"
//            followButton.borderWidth =!= 0
//            if (followTimelineButton != nil)
//            {
//                followTimelineButton.selected =!= false
//                followTimelineButton.enabled =!= false
//            }
        }
    }

//    func toggleFollowState() {
//        if let target = behaviorTarget where !target.isOwn {
//            target.toggleFollowState {
//                self.refreshFollowableBehavior()
//            }
//            refreshFollowableBehavior()
//        } else if let likeable = behaviorTarget as? Followable {
//            guard let controller = activeController() else { return }
//            controller.performSegueWithIdentifier("ShowUserList", sender: FollowableValue(followable: likeable))
//        }
//    }
    func togglePersonImage() {
        if let behaviorTarget = behaviorTarget {
            if  !behaviorTarget.isOwn {
                //print("\(behaviorTarget.followed)")
                var status = false
                if ("\(behaviorTarget.followed)" == "NotFollowing" || "\(behaviorTarget.followed)" == "Pending"){
                status = false
                }else if "\(behaviorTarget.followed)" == "Following"{
                 status = true
                }
                
                imagePerson.image =!= status ? UIImage(named: "dislikeImage.png") : UIImage(named: "likeImage.png")
            }
        }
    }
//    func showFollowers() {
//        if let likeable = behaviorTarget as? Followable {
//            guard let controller = activeController() else { return }
//            controller.performSegueWithIdentifier("ShowUserList", sender: FollowableValue(followable: likeable))
//        }
//    }
}
