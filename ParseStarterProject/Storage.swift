//
//  Storage.swift
//  Timeline
//
//  Created by Valentin Knabel on 10.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import Foundation
import Alamofire
import Parse

struct Storage {
    
    static var session: Session = {
        if let dict = NSUserDefaults.standardUserDefaults().dictionaryForKey("session") {
            return Session(dict: dict, parent: nil)
        } else {
            return Session(dict: [:], parent: nil)
        }
    }()
    
    static func save() {
        
        NSUserDefaults.standardUserDefaults().setValue(session.dict, forKey: "session")
        
        if Storage.session.unsyncedTimelineIncrement - Storage.session.activeTimelineIncrementSyncs > 0 {
            Storage.session.updateProduct(String.additionalTimelineProduct, success: { self.save() }, failure: { error in print("Auto-Sync failure \(String.additionalTimelineProduct): \(error)") })
        }
    }
    
    private static var urlSession: NSURLSession = {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.HTTPMaximumConnectionsPerHost = 15
        let session = NSURLSession(configuration: config)
        return session
        }()
    
}

extension Storage {
    
    static func addUser(user: User) {
        for u in session.users {
            if u.name == user.name {
                return
            }
        }
        session.users.append(user)
    }
    
}

extension Storage {
    
    static func logout(delete: Bool = true) {
//        main {
        let isFacebook = NSUserDefaults.standardUserDefaults().valueForKey("facebook_login")
        if(isFacebook != nil)
        {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("fb_username")
            NSUserDefaults.standardUserDefaults().removeObjectForKey("fb_email")
            NSUserDefaults.standardUserDefaults().removeObjectForKey("facebook_login")
            
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
        }
            PFUser.logOut()
        
            let drafts = Storage.session.drafts
            print(drafts.count)
            Storage.session = Session()
            Storage.session.drafts = drafts
            Storage.save()

//            if delete {
//                do {
//                    try NSFileManager.defaultManager().removeItemAtPath(Moment.basePath)
//                } catch _ {
//                }
//            }
            (UIApplication.sharedApplication().delegate as! AppDelegate).initializeRootViewController()
//        }
    }
    
    static func delete() {
        async {
            let oldUser = PFUser.currentUser()
            _ = PFInstallation.currentInstallation()
            
            _ = try? oldUser?.delete()
            
            PFUser.logOut()
            Storage.session = Session()
            Storage.save()
            
            Storage.performRequest(ApiRequest.UserDelete) { (json) -> Void in }
            
            do {
                try NSFileManager.defaultManager().removeItemAtPath(Moment.basePath)
            } catch _ {
            }

            main {
                (UIApplication.sharedApplication().delegate as! AppDelegate).initializeRootViewController()
            }
        }
    }
    
    static func performUpload(moment moment: Moment, timeline: Timeline, completion: (Response<AnyObject, NSError>) -> Void) {
        upload(
            Method.POST,
            ApiRequest.CreateVideo(NSData(), "").urlRequest.URLString,
            headers: ["X-Timeline-Authentication": Storage.session.webToken ?? ""],
            multipartFormData: { multipartFormData in
                if let timelineID = timeline.uuid!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true),
                    let url = moment.localVideoURL {
                        multipartFormData.appendBodyPart(data: timelineID, name: "timeline_id")
                        multipartFormData.appendBodyPart(fileURL: url, name: "video")
                        
                        if let text = moment.overlayText,
                            let textData = text.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true),
                            let color = moment.overlayColor,
                            let colorData = color.hexString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true),
                            let position = moment.overlayPosition,
                            let positionData = position.description.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true),
                            let size = moment.overlaySize,
                            let sizeData = size.description.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                        {
                            multipartFormData.appendBodyPart(data: textData, name: "overlay_text")
                            multipartFormData.appendBodyPart(data: colorData, name: "overlay_color")
                            multipartFormData.appendBodyPart(data: positionData, name: "overlay_position")
                            multipartFormData.appendBodyPart(data: sizeData, name: "overlay_size")
                        }
                }
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    //upload.responseString(completionHandler: println)
                    upload.responseJSON(completionHandler: completion)
                case .Failure(let encodingError):
                    print(encodingError)
                }
            }
        )
        
        
    }
    
    static func performRequest(request: ApiRequest, completion: ([String: AnyObject]) -> Void) {
        let t = urlSession.taskWith(request) { (data, response, error) -> Void in
            if let error = error {
                //print("Error: \(request.urlRequest.URL?.absoluteString ?? "")\n\(error)\n\n")
                return
            }
            
            func perform() {
                var error: NSError?
                var json : [String: AnyObject]?
                do {
                    guard let data = data else { throw NSError(domain: "Storage.performRequest", code: 0, userInfo: nil) }
                    let someJson: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
                    if let array = someJson as? [AnyObject] {
                        json = ["result": array]
                    } else if let dict = someJson as? [String: AnyObject] {
                        json = dict
                    } else {
                        json = nil
                    }
                } catch let error1 as NSError {
                    error = error1
                    json = nil
                    print(error)
                }
                json?["status_code"] = (response as! NSHTTPURLResponse).statusCode
                completion(json ?? ["error": error!.localizedDescription, "status_code": (response as! NSHTTPURLResponse).statusCode])
            }
            
            switch (response as! NSHTTPURLResponse).statusCode {
            case 401:
                main {
                    // Unauthorized
                    self.logout(false)
                    let alert = UIAlertController(title: local(.SessionAlertExpiredTitle), message: local(.SessionAlertExpiredMessage), preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: local(.SessionAlertExpiredActionDismiss), style: UIAlertActionStyle.Default, handler: nil))
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    let rootViewController = appDelegate.window?.rootViewController
                    rootViewController?.presentAlertController(alert)
                    // completion will not be called
                }
            case 200:
               // print("\((response as! NSHTTPURLResponse).statusCode): \(request.urlRequest.URLString)")
                perform()
            case 404, 500, 502, _:
               // print("\((response as! NSHTTPURLResponse).statusCode): \(request.urlRequest.URLString)")
                perform()
                
            }
        }
        t.resume()
    }
}