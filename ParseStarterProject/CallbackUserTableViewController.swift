//
//  CallbackUserTableViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 16.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import UIKit

class CallbackUserTableViewController: FlatUserTableViewController {

    var callback: (([User] -> ()) -> ())?

    override func refreshTableView() {
        callback? { u in
            self.users = u
            self.refreshControl?.endRefreshing()
        }
    }
}
