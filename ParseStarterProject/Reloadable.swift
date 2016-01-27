//
//  Reloadable.swift
//  Timeline
//
//  Created by Valentin Knabel on 10.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import UIKit
import ConclurerHook

extension HookKey {
    static var ForceReloadData: HookKey<String, (), ()> {
        return HookKey<String, (), ()>(rawValue: "\(__FILE__):\(__LINE__)")
    }
}


protocol Reloadable: class {
    func reloadData()
}

extension Reloadable {
    func setUpReloadable() -> AnyObject? {
        return serialHook.add(key: .ForceReloadData, closure: self.reloadData)
    }
}

extension UITableViewController: Reloadable {
    func reloadData() {
        main {
            self.tableView.reloadData()
        }
    }
}

extension UICollectionViewController: Reloadable {
    func reloadData() {
        main {
            self.collectionView?.reloadData()
        }
    }
}
