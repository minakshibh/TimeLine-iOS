//
//  Approveable.swift
//  Timeline
//
//  Created by Valentin Knabel on 11.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

protocol Approveable {
    // var needsApprovement: Bool

    func approve(completion: () -> ())
    func decline(completion: () -> ())
}

extension User: Approveable {
    
}