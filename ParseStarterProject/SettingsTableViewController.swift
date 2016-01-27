//
//  SettingsTableViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 06.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import Parse

class SettingsTableViewController: TintedHeaderTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        navigationItem.leftBarButtonItem = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let maxSections = tableView.numberOfSections - 1
        let maxRows = tableView.numberOfRowsInSection(maxSections) - 1
        switch (indexPath.section, indexPath.row) {
        case (maxSections, maxRows - 1):
            let alert = UIAlertController(title: LocalizedString.SettingsAlertLogoutTitle.localized, message: LocalizedString.SettingsAlertLogoutMessage.localized, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: LocalizedString.SettingsAlertLogoutActionCancel.localized, style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: LocalizedString.SettingsAlertLogoutActionLogout.localized, style: .Destructive, handler: { (_) -> Void in
                Storage.logout()
            }))
            presentAlertController(alert)
        case (maxSections, maxRows):
            let alert = UIAlertController(title: LocalizedString.SettingsAlertDeleteTitle.localized, message: LocalizedString.SettingsAlertDeleteMessage.localized, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: LocalizedString.SettingsAlertDeleteActionCancel.localized, style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: LocalizedString.SettingsAlertDeleteActionDelete.localized, style: .Destructive, handler: { (_) -> Void in
                Storage.delete()
                
            }))
            presentAlertController(alert)
        default:
            break
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}