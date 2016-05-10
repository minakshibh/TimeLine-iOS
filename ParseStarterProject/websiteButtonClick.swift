//
//  LikeableBehavior.swift
//  Timeline
//
//  Created by Valentin Knabel on 07.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import SWFrameButton

protocol websiteButtonClick {
    associatedtype TargetBehaviorType: Named1
    var behaviorTarget: TargetBehaviorType? { get }
    var btnWebsite: SWFrameButton! { get }
}

private extension UIColor {
    static var likeableTintColor: UIColor! {
        return UIColor.from(hexString: "0A256C")
    }
}

extension websiteButtonClick where TargetBehaviorType: Ownable {

    func refreshwebsiteButtonClick() {

        if let behaviorTarget = behaviorTarget {

        } else {
           
        }
        
//        btnWebsite.setTitle(behaviorTarget?.website, forState: .Normal)

//
//                var websiteStr:String = ""
//                if NSUserDefaults.standardUserDefaults().valueForKey("user_website") != nil {
//                    websiteStr = "\(NSUserDefaults.standardUserDefaults().valueForKey("user_website")!)"
//                    btnWebsite.setTitle(websiteStr, forState: .Normal)
//                }
//                if NSUserDefaults.standardUserDefaults().valueForKey("user_website") == nil {
//                    websiteStr = " "
//                    btnWebsite.setTitle(websiteStr, forState: .Normal)
//                }
//                
        

    }

    func websiteButtonClickAction() {
        
        let buttonTitle = btnWebsite.currentTitle!  as String
        let check = buttonTitle.stringByReplacingOccurrencesOfString("Website: ", withString: "")
        
        var resultingStr:String = ""
//        if check.length != 0 {
//            resultingStr = buttonTitle
//        }else{
//
//        }
        resultingStr = "http://\(check)"
        print(resultingStr)

        
        UIApplication.sharedApplication().openURL(NSURL(string: resultingStr)!)

    }
    
    
    
}
