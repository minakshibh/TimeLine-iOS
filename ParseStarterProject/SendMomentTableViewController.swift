//
//  SendMomentCollectionViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 14.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

class SendMomentTableViewController: CommonTimelineTableViewController {

    var moment: Moment!
    var selectedTimeline: Timeline?
    var selectedIndex: Int? {
        didSet {
            selectedTimeline = self.users.first!.timelines[selectedIndex!]
            switch (oldValue, selectedIndex) {
            case (nil, _):
                let button = UIBarButtonItem(image: UIImage(assetIdentifier: .SendToTimelineBar), style: UIBarButtonItemStyle.Plain, target: self, action: "sendMoment")
                self.navigationItem.setRightBarButtonItem(button, animated: true)
            default:
                break
            }
        }
    }
    var headerView: DraftPreviewCollectionReusableView?
    var barView: SendMomentBarCollectionReusableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tabBarController?.delegate = self
        //navigationController?.delegate = self

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        let draftPreview = NSBundle.mainBundle().loadNib(.DraftPreview, owner: self)[0] as? DraftPreview
        draftPreview?.moment = moment
        tableView.addParallaxWithView(draftPreview, andHeight: tableView.bounds.size.width)
        
        users = [Storage.session.currentUser!]
        
        if let _ = selectedTimeline {
            sendMoment()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: IBAction
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Upload" {
            let dest = segue.destinationViewController as! ModalUploadViewController
            dest.moment = moment
            dest.timeline = selectedTimeline!
        } else {
            super.prepareForSegue(segue, sender: sender)
        }
    }
    
    @IBAction func sendMoment() {
        performSegueWithIdentifier("Upload", sender: nil)
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    // MARK: UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if selectedIndex != indexPath.row {
            if let selectedIndex = selectedIndex {
                tableView.deselectRowAtIndexPath(NSIndexPath(forRow: selectedIndex, inSection: 0), animated: true)
            }
            selectedIndex = indexPath.row
        }
    }
    
}
