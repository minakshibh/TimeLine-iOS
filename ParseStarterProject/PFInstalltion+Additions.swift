//
//  PFInstalltion+Additions.swift
//  Timeline
//
//  Created by Valentin Knabel on 31.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import Foundation
import Parse


extension PFInstallation {
    
    var user: PFUser? {
        get {
            do {
                try self.fetchIfNeeded()
                return self["user"] as? PFUser
            } catch {
                return nil
            }
        }
        set {
            self["user"] = newValue
        }
    }
    
}