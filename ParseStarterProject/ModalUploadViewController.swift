//
//  ModalUploadViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 17.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import Alamofire

class ModalUploadViewController: UIViewController {

    var moment: Moment!
    var timeline: Timeline!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tabBarController?.delegate = self
        //navigationController?.delegate = self

        //navigationItem.hidesBackButton = true
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        // Do any additional setup after loading the view.
        
        Storage.performUpload(moment: moment, timeline: timeline) { (response: Response<AnyObject, NSError>) -> Void in
            guard let json = response.result.value else { return }
            if let dict = json as? [String: AnyObject] {
                let state = SynchronizationState(dict: dict, parent: nil)
                if let _ = dict["timeline_id"] as? UUID,
                    let contentType = dict["video_content_type"] as? String,
                    let _remoteThumbURLString = dict["video_thumb"] as? String,
                    let remoteThumbURL = NSURL(string: _remoteThumbURLString),
                    let videoSize = dict["video_file_size"] as? Int,
                    let _remoteVideoURLString = dict["video_url"] as? String,
                    let remoteVideoURL = NSURL(string: _remoteVideoURLString)
                {
                    self.moment.contentType = contentType
                    self.moment.state = state
                    self.moment.remoteThumbURL = remoteThumbURL
                    self.moment.size = videoSize
                    self.moment.remoteVideoURL = remoteVideoURL
                    self.timeline.moments.append(self.moment)
                    self.moment.parent = self.timeline
                    
                    for i in 0..<Storage.session.drafts.count {
                        let draft = Storage.session.drafts[i]
                        if draft.pathName == self.moment.pathName {
                            Storage.session.drafts.removeAtIndex(i)
                            break
                        }
                    }
                    
                    Storage.save()
                    
                    main {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    
                    return
                }
            } else {
                main {
                    let message: String
                    if let json = json as? [String: AnyObject],
                        let error = json["error"] as? String
                    {
                        message = error
                    } else {
                        message = local(.MomentAlertUploadErrorMessageDefault)
                    }
                    let alert = UIAlertController(title: local(.MomentAlertUploadErrorTitle), message: message, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: local(.MomentAlertUploadErrorActionDismiss), style: .Default, handler: { _ in
                        delay(0.1) {
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                    }))
                    self.presentAlertController(alert)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
