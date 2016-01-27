//
//  PushFetchViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 05.09.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

enum DeepLink {
    typealias Name = String
    typealias ExternalID = String
    
    case UserLink(Name, ExternalID, UUID)
    case TimelineLink(Name, UUID)
    case MomentLink(Name, UUID, UUID)
    
    static func from(payload payload: [String: AnyObject]?) -> DeepLink? {
        if let payload = payload {
            let link: DeepLink?
            if let name = payload["name"] as? String,
                let tid = payload["timeline_id"] as? String,
                let vid = payload["video_id"] as? String
            {
                // deep link to video
                link = DeepLink.MomentLink(name, tid, vid)
            }
            else if let eid = payload["external"] as? String,
                let name = payload["name"] as? String,
                let uid = payload["user_id"] as? String
            {
                // deep link to profile
                link = DeepLink.UserLink(name, eid, uid)
            }
            else if let name = payload["name"] as? String,
                let tid = payload["timeline_id"] as? String
            {
                link = DeepLink.TimelineLink(name, tid)
            } else {
                link = nil
            }
            return link
        }
        return nil
    }
    
    static func user(uuid uuid: UUID, completion: (User) -> Void) {
        if let user = Storage.findUser(uuid) {
            completion(user)
        } else {
            Storage.performRequest(ApiRequest.UserProfile(uuid)) { json in
                if let _ = json["error"] {
                    delay(1) {
                        self.user(uuid: uuid, completion: completion)
                    }
                }
                
                let user = User(dict: json, parent: nil)
                Storage.session.users.append(user)
                Storage.save()
                completion(user)
            }
        }
    }
    
    static func timeline(uuid uuid: UUID, completion: (Timeline) -> Void) {
        if let timeline = Storage.findTimeline(uuid) {
            timeline.reloadMoments {
                Storage.save()
                completion(timeline)
            }
        } else {
            Storage.performRequest(ApiRequest.ViewTimeline(uuid)) { json in
                if let _ = json["error"] {
                    delay(1) {
                        self.timeline(uuid: uuid, completion: completion)
                    }
                    return
                }
                
                let timeline = Timeline(dict: json, parent: nil)
                let uid = json["user_id"] as! UUID
                self.user(uuid: uid) { user in
                    user.timelines.append(timeline)
                    Storage.save()
                    
                    timeline.reloadMoments {
                        completion(timeline)
                    }
                }
            }
        }
    }
    
}

class PushFetchViewController: UIViewController {
    
    var link: DeepLink!
    var finished: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()
    }
    
    func fetchData() {
        main {
        switch self.link! {
        case let .UserLink(_, _, uuid):
            DeepLink.user(uuid: uuid) { u in
                self.performSegueWithIdentifier("ShowUser", sender: u)
            }
            
        case let .TimelineLink(_, uuid):
            DeepLink.timeline(uuid: uuid) { t in
                self.performSegueWithIdentifier("ShowTimeline", sender: t)
            }
            
        case let .MomentLink(_, tid, vid):
            DeepLink.timeline(uuid: tid) { t in
                t.reloadMoments {
                    let m = Storage.findMoment(vid)
                    self.performSegueWithIdentifier("ShowMoment", sender: m)
                }
            }
        }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        finished = true
        
        switch segue.identifier ?? "" {
        case "ShowUser":
            let dest = (segue.destinationViewController as! UINavigationController).topViewController as! UserSummaryTableViewController
            dest.user = sender as! User
            
        case "ShowTimeline":
            let dest = segue.destinationViewController as! TimelinePlaybackViewController
            dest.timeline = sender as! Timeline
            
        case "ShowMoment":
            let dest = segue.destinationViewController as! TimelinePlaybackViewController
            dest.moment = sender as? Moment
            
        default:
            break
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if finished {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}
