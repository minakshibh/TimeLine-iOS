//
//  ProfileImageView.swift
//  Timeline
//
//  Created by Valentin Knabel on 13.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import Parse

private let userProfileImageCache = NSCache()

class ProfileImageView: RoundImageView {
    
    var user: User? {
        didSet {
            setNeedsUpdate()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(configuration: (ProfileImageView) -> Void) {
        super.init(frame: CGRectZero)
        contentMode = .ScaleAspectFill
        backgroundColor = UIColor(white: 0.854, alpha: 1.0)
        configuration(self)
    }
    
    func setUserImage(image: UIImage) {
        if let externalID = self.user?.externalID {
            userProfileImageCache.setObject(image, forKey: externalID)
            main {
                self.image = image
            }
            async {
                PFUser(withoutDataWithObjectId: externalID).setProfileImageInBackground(image, handler: nil, progressBlock: nil)
            }
        } else {
            main { self.image = UIImage(assetIdentifier: .DefaultUserProfile) }
        }
    }
    
    func setNeedsUpdate() {
        let isFacebook = NSUserDefaults.standardUserDefaults().valueForKey("facebook_login")
       
        
        if(isFacebook != nil)
        {
            if let externalID = self.user?.externalID {
                if let image = userProfileImageCache.objectForKey(externalID) as? UIImage {
                    self.image = image
                    return
                }
            
            let facebooIDStr = NSUserDefaults.standardUserDefaults().valueForKey("facebookID") as! String
            
            let url = NSURL(string: "https://graph.facebook.com/\(facebooIDStr)/picture?type=large&return_ssl_resources=1")
            let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
//            imageURL.image = UIImage(data: data!)
                
                self.image = UIImage(data: data!)
           
            }
            
        }else{
            if let externalID = self.user?.externalID {
                if let image = userProfileImageCache.objectForKey(externalID) as? UIImage {
                    self.image = image
                    return
                }
                self.image = UIImage(assetIdentifier: .DefaultUserProfile)
                PFUser(withoutDataWithObjectId: externalID).getProfileImageInBackground { (image, error) -> Void in
                    if let image = image {
                        userProfileImageCache.setObject(image, forKey: externalID)
                        main {
                            self.image = image
                        }
                    } else {
                        main { self.image = UIImage(assetIdentifier: .DefaultUserProfile) }
                    }
                }
            
            } else {
                self.image = UIImage(assetIdentifier: .DefaultUserProfile)
            }
        
        }
    }
    
}
