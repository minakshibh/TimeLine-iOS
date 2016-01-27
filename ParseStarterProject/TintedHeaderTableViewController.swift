//
//  TintedHeaderTableViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 06.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

class TintedHeaderTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearsSelectionOnViewWillAppear = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(selected, animated: false)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = tableView.tintColor
            header.textLabel?.font = UIFont.boldSystemFontOfSize(13)
        }
    }

}
