//
//  PFUser+Additions.swift
//  Timeline
//
//  Created by Valentin Knabel on 06.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import Foundation
import Parse

private let profilePictureQueue = SerialOperationQueue("profile_picture")

extension PFUser {
    
    func badgeFollowingInBackground(completion: (Int) -> Void) {
        completion(NSUserDefaults.standardUserDefaults().integerForKey("badgeFollowing"))
    }
    
    func badgeUserInBackground(completion: (Int) -> Void) {
        completion(NSUserDefaults.standardUserDefaults().integerForKey("badgeUser"))
    }
    
    func badgeMineInBackground(completion: (Int) -> Void) {
        completion(NSUserDefaults.standardUserDefaults().integerForKey("badgeMine"))
    }
    
    func badgePendingInBackground(completion: (Int) -> Void) {
        completion(NSUserDefaults.standardUserDefaults().integerForKey("badgePending"))
    }
    
    func badgeUserAndPendingInBackground(completion: (Int, Int) -> Void) {
        completion(NSUserDefaults.standardUserDefaults().integerForKey("badgeUser"), NSUserDefaults.standardUserDefaults().integerForKey("badgePending"))
    }
    
    func badgeMineAndFollowingInBackground(completion: (Int, Int) -> Void) {
        completion(NSUserDefaults.standardUserDefaults().integerForKey("badgeMine"), NSUserDefaults.standardUserDefaults().integerForKey("badgeFollowing"))
    }
    
    func increaseBadgeFollowingInBackground() {
        let key = "badgeFollowing"
        let def = NSUserDefaults.standardUserDefaults()
        var i = def.integerForKey(key)
        def.setInteger(++i, forKey: key)
    }
    
    func increaseBadgeUserInBackground() {
        let key = "badgeUser"
        let def = NSUserDefaults.standardUserDefaults()
        var i = def.integerForKey(key)
        def.setInteger(++i, forKey: key)
    }
    
    func increaseBadgeMineInBackground() {
        let key = "badgeMine"
        let def = NSUserDefaults.standardUserDefaults()
        var i = def.integerForKey(key)
        def.setInteger(++i, forKey: key)
    }
    
    func increaseBadgePendingInBackground() {
        let key = "badgePending"
        let def = NSUserDefaults.standardUserDefaults()
        var i = def.integerForKey(key)
        def.setInteger(++i, forKey: key)
    }
    
    func resetBadgeFollowingInBackground() {
        let key = "badgeFollowing"
        let def = NSUserDefaults.standardUserDefaults()
        def.setInteger(0, forKey: key)
    }
    
    func resetBadgeUserInBackground() {
        let key = "badgeUser"
        let def = NSUserDefaults.standardUserDefaults()
        def.setInteger(0, forKey: key)
    }
    
    func resetBadgeMineInBackground() {
        let key = "badgeMine"
        let def = NSUserDefaults.standardUserDefaults()
        def.setInteger(0, forKey: key)
    }
    
    func resetBadgePendingInBackground() {
        let key = "badgePending"
        let def = NSUserDefaults.standardUserDefaults()
        def.setInteger(0, forKey: key)
    }
    
    
    
    private var profilePicture: PFFile? {
        get {
            do {
                try self.fetchIfNeeded()
                return self.valueForKey("profile_picture") as? PFFile
            } catch {
                return nil
            }
        }
        set {
            self["profile_picture"] = newValue
        }
    }
    
    func getProfileImageInBackground(handler: (UIImage?, NSError?) -> Void) {
        profilePictureQueue.addOperationWithBlock {
            ((try? self.fetchIfNeeded())?.valueForKey("profile_picture") as? PFFile)?.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if let data = data {
                    handler(UIImage(data: data), error)
                } else {
                    handler(nil, error)
                }
            })
        }
    }
    
    func setProfileImageInBackground(image: UIImage, handler: PFBooleanResultBlock? = nil, progressBlock: PFProgressBlock? = nil) {
        profilePictureQueue.addOperationWithBlock {
            guard let data = UIImageJPEGRepresentation(image, 0.85) else { return }
            let file = PFFile(name: "profile.png", data: data)
            file?.saveInBackgroundWithBlock(handler, progressBlock: progressBlock)
            
            self.profilePicture = file
            self.saveInBackground()
        }
    }
    
}
