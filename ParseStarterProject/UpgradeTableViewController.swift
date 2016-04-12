//
//  UpgradeTableViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 01.09.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import RMStore


class UpgradeTableViewController: TintedHeaderTableViewController {
    
    @IBOutlet var currentTimelineCountLabel: UILabel!
    @IBOutlet var maximumTimelineCountLabel: UILabel!
    @IBOutlet var additionalTimelinePriceLabel: UILabel!
    @IBOutlet var additionalTimelinePurchaseLabel: UILabel!
    @IBOutlet var unsyncedAdditionalTimelinesLabel: UILabel!
    @IBOutlet var unsyncedAdditionalTimelinesDescriptionLabel: UILabel!
    
    var requestedPurchase: Bool = false
    var popOnAppear: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearsSelectionOnViewWillAppear = true
    }
    
    private func refreshUnsynced() {
        currentTimelineCountLabel.text = (Storage.session.currentUser?.timelines.count ?? 0).description
        maximumTimelineCountLabel.text = (Storage.session.allowedTimelinesCount ?? 0).description
        unsyncedAdditionalTimelinesLabel.text = Storage.session.unsyncedTimelineIncrement.description
        
        unsyncedAdditionalTimelinesDescriptionLabel.textColor = Storage.session.unsyncedTimelineIncrement < 1 ? UIColor(red: 0x8E/255.0, green: 0x8E/255.0, blue: 0x93/255.0, alpha: 1.0) : .darkTextColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
        Storage.session.updateProduct(String.additionalTimelineProduct, success: refreshUnsynced, failure: { _ in })
        
        if popOnAppear && requestedPurchase {
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            self.refreshUnsynced()
            
            Storage.session.requestProducts { valids in
                for vp in valids {
                    print(vp)
                    switch vp.productIdentifier {
                    case String.additionalTimelineProduct:
                        self.additionalTimelinePurchaseLabel.text = "One Additional Feedeo"
                        self.additionalTimelinePriceLabel.text = vp.localizedPrice
                        self.additionalTimelinePurchaseLabel.textColor = UIColor.redNavbarColor()
//                        self.additionalTimelinePurchaseLabel.textColor = UIColor(red: 0xEB/255.0, green: 0x81/255.0, blue: 0x28/255.0, alpha: 1.0)
                        let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: self.tableView.numberOfRowsInSection(0) - 1, inSection: 0))
                        cell?.selectionStyle = .Default
                    default:
                        break
                    }
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier ?? "" {
        case "AdditionalTimeline":
            self.requestedPurchase = true
            let dest = segue.destinationViewController as! PendingInAppViewController
            dest.productIdentifier = String.additionalTimelineProduct
        default:
            break
        }
    }
    
}
