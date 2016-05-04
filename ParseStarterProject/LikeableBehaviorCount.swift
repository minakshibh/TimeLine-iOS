//
//  LikeableBehavior.swift
//  Timeline
//
//  Created by Valentin Knabel on 07.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import SWFrameButton

protocol LikeableBehaviorCount {
    typealias TargetBehaviorType: Likeable,Followable,Named1
    var behaviorTarget: TargetBehaviorType? { get }
//    var likeButton: SWFrameButton! { get }
//    var likeTimelineButton: UIButton! { get }
    var imageheart: UIImageView! { get }
     var lblBio: UILabel! { get }
}

private extension UIColor {
    static var likeableTintColor: UIColor! {
        return UIColor.from(hexString: "FF502C")
    }
}

extension LikeableBehaviorCount where TargetBehaviorType: Ownable {

    func refreshLikeableBehaviorCount() {
//        likeButton.cornerRadius =!= 7
//        likeButton.normalImage =!= UIImage(assetIdentifier: .LikeableButton)
//        likeButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 0)
//
//        likeButton.setNeedsLayout()

        if let behaviorTarget = behaviorTarget {
//            likeButton.setTitle("\(behaviorTarget.likesCount)", forState: .Normal)
            if behaviorTarget.isOwn{
                if PFUser.currentUser()?.authenticated ?? false {
                    let user = PFUser.currentUser()!
                    var bioStr:String = ""
                    if user.objectForKey("bio") != nil {
                        bioStr = "\(user.objectForKey("bio")!)"
                        let attributedTextBio: NSMutableAttributedString = NSMutableAttributedString(string: "Bio: \(bioStr ?? "")")
                        attributedTextBio.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(18)], range: NSRange(location: 0, length: 4))
                        lblBio.attributedText = attributedTextBio
                    }
                }
            }else{
            let attributedTextBio: NSMutableAttributedString = NSMutableAttributedString(string: "Bio: \(behaviorTarget.bio ?? "")")
            attributedTextBio.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(18)], range: NSRange(location: 0, length: 4))
            lblBio.attributedText = attributedTextBio
            //        lblBio.text =!= behaviorTarget?.bio ?? ""
            }
            
            
            
            
            if behaviorTarget.isOwn{
                if(behaviorTarget.likesCount > 0){
                    imageheart.image = UIImage(named: "RedHeart.png")
                }else{
                    imageheart.image = UIImage(named: "whiteHeart.png")
                }
            }else{
                imageheart.image =!= behaviorTarget.liked ? UIImage(assetIdentifier: .RedHeart) : UIImage(assetIdentifier: .whiteHeart)
            }
//            likeButton.borderWidth =!= 0
//            likeButton.tintColor =!=  UIColor.blackColor()
//            if (likeTimelineButton != nil)
//            {
//                likeTimelineButton.hidden =!= behaviorTarget.isOwn ? true : false
//                likeTimelineButton.selected =!= behaviorTarget.liked
//                likeTimelineButton.enabled =!= true
//                likeTimelineButton.normalImage =!= behaviorTarget.liked ? UIImage(assetIdentifier: .RedHeart) : UIImage(assetIdentifier: .whiteHeart)
//            }
        } else {
//            likeButton.enabled =!= false
//            likeButton.selected =!= false
//            likeButton.normalTitle =!= "0"
//            likeButton.borderWidth =!= 0
//            if (likeTimelineButton != nil)
//            {
//                likeTimelineButton.selected =!= false
//                likeTimelineButton.enabled =!= false
//            }
        }
    }

//    func toggleLiked() {
//        if let target = behaviorTarget where !target.isOwn {
//        target.toggleLiked {
//            self.refreshLikeableBehavior()
//        }
//            refreshLikeableBehavior()
//        }
//        else if let likeable = behaviorTarget as? Likeable {
//            guard let controller = activeController() else { return }
//            controller.performSegueWithIdentifier("ShowUserList", sender: LikeableValue(likeable: likeable))
//        }
//    }
//    
    func changeHeartImage() {
         if let behaviorTarget = behaviorTarget {
         if  !behaviorTarget.isOwn {
           imageheart.image =!= behaviorTarget.liked ? UIImage(assetIdentifier: .RedHeart) : UIImage(assetIdentifier: .whiteHeart)
        }
        }
    }
//    func showLikes() {
//        if let likeable = behaviorTarget as? Likeable {
//            guard let controller = activeController() else { return }
//            controller.performSegueWithIdentifier("ShowUserList", sender: LikeableValue(likeable: likeable))
//        }
//    }
}
