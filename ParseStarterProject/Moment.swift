//
//  Moment.swift
//  Timeline
//
//  Created by Valentin Knabel on 10.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import Foundation
import Alamofire

func alternative<T>(lhs: T?, rhs: T?) ->T? {
    if let lhs = lhs {
        return lhs
    }
    return rhs
}

func maybeStringToURL(string: String?) -> NSURL? {
    if let s = string {
        return NSURL(string: s)
    } else {
        return nil
    }
}

func maybeURLToString(url: NSURL?) -> String? {
    if let u = url {
        return u.absoluteString
    } else {
        return nil
    }
}

class Moment: Synchronized, DictConvertable {
    var state: SynchronizationState
    
    var remoteStreamURL: NSURL?
    var remoteVideoURL: NSURL?
    var remoteThumbURL: NSURL?
    var contentType: String?
    var id : String?
    var size: Int?
    var duration: Int = 0
    
    var overlayPosition: Float?
    var overlayText: String?
    var overlaySize: Int?
    var overlayColor: UIColor?
    
    var localThumbURL: NSURL? {
        if let l = self.pathName {
            return Moment.documentURL(l, suffix: "jpg")
        }
        return nil
    }
    var localVideoURL: NSURL? {
        if let l = self.pathName {
            return Moment.documentURL(l, suffix: "mp4")
        }
        return nil
    }
    var pathName: String?
    var persistent: Bool
    weak var parent: ParentType?
    typealias ParentType = Timeline
    
    required init(persistent: Bool, pathName: String?, remoteStreamURL: NSURL?, remoteVideoURL: NSURL?, remoteThumbURL: NSURL?, size: Int?, duration: Int?, contentType: String?, overlayPosition: Float?, overlayText: String?, overlaySize: Int?, overlayColor: UIColor?, state: SynchronizationState = .LocalOnly, parent: ParentType? = nil) {
        self.persistent = persistent
        self.pathName = pathName ?? Moment.newName()
        self.remoteStreamURL = remoteStreamURL
        self.remoteVideoURL = remoteVideoURL
        self.remoteThumbURL = remoteThumbURL
        self.size = size
        self.duration = duration ?? 0
        self.contentType = contentType
        self.overlayColor = overlayColor
        self.overlayPosition = overlayPosition
        self.overlaySize = overlaySize
        self.overlayText = overlayText
        self.state = state
        self.parent = parent
    }
    
    convenience required init(dict: [String: AnyObject], parent: ParentType? = nil) {
        
        let bug = (dict["persistent"] as? Bool) ?? true
        let state = SynchronizationState(dict: dict["state"] as? [String: AnyObject] ?? dict)
        let duration = dict["duration"] as? Float
        self.init(
            persistent: bug,
            pathName: alternative(dict["local_name"] as? String, rhs: dict["path_name"] as? String),
            remoteStreamURL: maybeStringToURL(dict["video_lowres"] as? String),
            remoteVideoURL: alternative(maybeStringToURL(dict["remote_url"] as? String), rhs: maybeStringToURL(dict["video_url"] as? String)),
            remoteThumbURL: maybeStringToURL(dict["video_thumb"] as? String),
            size: dict["video_file_size"] as? Int,
            duration: duration != nil ? Int(floor(duration!)) : (dict["moments_duration"] as? Int),
            contentType: dict["video_content_type"] as? String,
            overlayPosition: dict["overlay_position"] as? Float,
            overlayText: dict["overlay_text"] as? String,
            overlaySize: dict["overlay_size"] as? Int,
            overlayColor: UIColor.from(hexString: dict["overlay_color"] as? String),
            state: state,
            parent: parent
        )
    }
    
    var dict: [String: AnyObject] {
        let optDict: [String: AnyObject?] = ["persistent": persistent, "path_name": pathName, "video_url": maybeURLToString(remoteVideoURL), "video_lowres": maybeURLToString(remoteStreamURL), "video_thumb": maybeURLToString(remoteThumbURL), "video_file_size": size, "video_content_type": contentType, "state": state.dict, "duration": duration ?? 0, "overlay_position": overlayPosition, "overlay_text": overlayText, "overlay_size": overlaySize, "overlay_color": overlayColor?.hexString]
        let tuples = optDict.filter {
            return $0.1 != nil
        }
        var dict = [String: AnyObject]()
        for (k,v) in tuples {
            dict[k] = v!
        }
        return dict
    }
}

extension Moment {
    
    static func newName() -> String {
        return String(characters: String.NameCharacters, length: 20)
    }
    
    static var basePath: String {
        let path = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory, .UserDomainMask, true).first! 
        return "\(path)/moment"
    }
    
    static func documentURL(name: String, suffix: String) -> NSURL {
        return NSURL(fileURLWithPath: "\(Moment.basePath)/\(name).\(suffix)")
    }
    
    func removeMoment(completion: () -> ()) {
        self.persistent = false
        async {
            if NSFileManager.defaultManager().fileExistsAtPath(self.localVideoURL?.path ?? "") {
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(self.localVideoURL?.path ?? "")
                } catch _ {
                }
            }
            Storage.save()
            completion()
        }
    }
    
    func downloadMoment(completion: () -> ()) {
        downloadMomentCounter++
        if let remoteVideoURL = remoteVideoURL as? URLStringConvertible {
            var turl: NSURL? = nil
            let request: Request = download(Method.GET, remoteVideoURL, headers: nil, destination: { (url, response) -> NSURL in
                downloadMomentCounter--
                turl = url
                return url
            })
            request.response(completionHandler: { (urlReq, resp, data, error) -> Void in
                if let _ = data, let url = turl {
                    if self.pathName == nil {
                        self.pathName = Moment.newName()
                    }
                    do {
                        try NSFileManager.defaultManager().moveItemAtURL(url, toURL: self.localVideoURL!)
                        self.persistent = true
                    } catch _ {
                        self.persistent = false
                    }
                    Storage.save()
                    completion()
                }
            })
        }

    }
    
}

var downloadMomentCounter = 0 {
    didSet {
        if downloadMomentCounter > 0 {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        } else {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
}
