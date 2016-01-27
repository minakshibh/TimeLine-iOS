//
//  UserApproveViewCell.swift
//  Timeline
//
//  Created by Valentin Knabel on 07.09.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

class UserApproveViewCell: MGSwipeTableCell {
   
    
    private var userView: TimelineTableHeaderView!
    
    var answerCallback: MGSwipeButtonCallback?
    var user: User? {
        get {
            return userView.user
        }
        set {
            userView.user = newValue
            
            refresh()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.userView = UINib(nibName: "TimelineTableHeaderView", bundle: nil).instantiateWithOwner(self, options: [:]).first as! TimelineTableHeaderView
        self.contentView.addSubview(userView)
        self.userView.frame.size = self.bounds.size
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.userView = UINib(nibName: "TimelineTableHeaderView", bundle: nil).instantiateWithOwner(self, options: [:]).first as! TimelineTableHeaderView
        self.contentView.addSubview(userView)
        self.userView.frame.size = self.bounds.size
    }
    
    func refresh() {
        main {
            self.userView.refresh()
            
            let newValue = self.user
            
            let redColor = UIColor(red: 235/255.0, green: 48/225.0, blue: 83/255.0, alpha: 1.0)
            let likeColor = UIColor(red: 244/255.0, green: 98/225.0, blue: 66/255.0, alpha: 1.0)
            let followColor = UIColor(red: 253/255.0, green: 148/255.0, blue: 39/255.0, alpha: 1.0)
            let shareButton = MGSwipeButton(title: "", icon: UIImage(assetIdentifier: .Share), backgroundColor: followColor, callback: self.share)
            shareButton.tintColor = UIColor.whiteColor()
            self.leftButtons = [shareButton]
            
            if newValue?.state.uuid == Storage.session.currentUser?.state.uuid {
                self.rightButtons = [
                    
                ]
            } else if let _ = self.user {
                let approveButton = MGSwipeButton(title: "", icon: UIImage(assetIdentifier: .Approve), backgroundColor: followColor, callback: self.approve)
                approveButton.tintColor = UIColor.whiteColor()
                let declineButton = MGSwipeButton(title: "", icon: UIImage(assetIdentifier: .Decline), backgroundColor: likeColor, callback: self.decline)
                declineButton.tintColor = UIColor.whiteColor()
                let deleteButton = MGSwipeButton(title: "", icon: UIImage(assetIdentifier: self.user?.blocked ?? false ? .Unreport : .Report), backgroundColor: redColor, callback: self.report)
                deleteButton.tintColor = UIColor.whiteColor()
                self.rightButtons = [
                    deleteButton,
                    declineButton,
                    approveButton
                ]
                
            }
            
            self.refreshButtons(false)
        }
    }
    
    func approve(button: MGSwipeTableCell!) -> Bool {
        user?.approve {
            self.refresh()
        }
        refresh()
        answerCallback?(button)
        return true
    }
    
    func decline(button: MGSwipeTableCell!) -> Bool {
        user?.decline {
            self.refresh()
        }
        refresh()
        answerCallback?(button)
        return true
    }
    
    func report(button: MGSwipeTableCell!) -> Bool {
        let alert = UIAlertController(
            title: local(!self.user!.blocked ? LocalizedString.UserAlertBlockTitle : LocalizedString.UserAlertUnblockTitle),
            message: lformat(!self.user!.blocked ? LocalizedString.UserAlertBlockMessage1s : LocalizedString.UserAlertUnblockMessage1s, args: user?.name ?? ""),
            preferredStyle: .Alert
        )
        alert.addAction(UIAlertAction(
            title: local(!self.user!.blocked ? LocalizedString.UserAlertBlockActionCancel : LocalizedString.UserAlertUnblockActionCancel),
            style: .Cancel,
            handler: nil
            ))
        alert.addAction(UIAlertAction(
            title: local(!self.user!.blocked ? LocalizedString.UserAlertBlockActionBlock : LocalizedString.UserAlertUnblockActionUnblock),
            style: .Destructive,
            handler: { (_) -> Void in
                self.user?.decline { }
                (self.user!.blocked ? self.user!.unblock : self.user!.block) {
                    self.refresh()
                }
                self.refresh()
        }))
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let rootViewController = appDelegate.window?.rootViewController
        (rootViewController?.presentedViewController ?? rootViewController)?.presentAlertController(alert)
        
        return true
    }
    
    func share(button: MGSwipeTableCell!) -> Bool {
        let urlString = lformat(LocalizedString.UserStringShareURL1s, args: user?.name ?? "")
        let messageString = lformat(LocalizedString.UserStringShareMessage1s, args: user?.name ?? "")
        let activities = [messageString, NSURL(string: urlString)!]
        let controller = UIActivityViewController(activityItems: activities, applicationActivities: nil)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let rootViewController = appDelegate.window?.rootViewController
        (rootViewController?.presentedViewController ?? rootViewController)?.presentActivityViewController(controller)
        return true
    }
    
}
