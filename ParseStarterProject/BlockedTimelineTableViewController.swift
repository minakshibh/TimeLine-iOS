//
//  BlockedTimelineTableViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 07.09.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

class BlockedTimelineTableViewController: FlatTimelineTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func refreshTableView() {
        var first = true
        print("refresh")
        Timeline.getTimelines(ApiRequest.CurrentTimelineBlocked, completion: { (tls) -> Void in
            print(tls)
            self.timelines = tls
            if !first {
                main { self.refreshControl?.endRefreshing() }
            } else {
                first = false
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func removeTimelineFromCache(uuid: UUID) {
        Storage.session.currentTimelineBlockedCache = Storage.session.currentTimelineBlockedCache.filter { $0 != uuid }
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
