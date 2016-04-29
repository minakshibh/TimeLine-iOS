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
//    var followTimelineButton: UIButton! { get }
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
//            followButton.setTitle("\(target.followersCount)", forState: .Normal)
            if(target.followersCount > 0){
                imagePerson.image = UIImage(named: "dislikeImage.png")
            }else{
               imagePerson.image = UIImage(named: "likeImage.png")
            }
            
            if target.isOwn{
                if(target.followersCount > 0){
                    imagePerson.image = UIImage(named: "dislikeImage.png")
                }else{
                    imagePerson.image = UIImage(named: "likeImage.png")
                }
            }else{
                if  !target.isOwn {
                    print("\(target.followed)")
                    var status = false
                    if ("\(target.followed)" == "Following" || "\(target.followed)" == "Pending"){
                        status = true
                    }else if "\(target.followed)" == "NotFollowing"{
                        status = false
                    }
                    
                    imagePerson.image =!= status ? UIImage(named: "dislikeImage.png") : UIImage(named: "likeImage.png")
                }

            }
            print("\(target.followed)")
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
                print("\(behaviorTarget.followed)")
                var status = false
                if ("\(behaviorTarget.followed)" == "Following" || "\(behaviorTarget.followed)" == "Pending"){
                status = true
                }else if "\(behaviorTarget.followed)" == "NotFollowing"{
                 status = false
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
