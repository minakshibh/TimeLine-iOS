//
//  NamedBehavior.swift
//  Timeline
//
//  Created by Valentin Knabel on 08.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

protocol NamedBehavior {
    typealias TargetBehaviorType: Named
    var behaviorTarget: TargetBehaviorType? { get }
    var nameLabel: UILabel! { get }
//    var nameLabel1: UILabel! { get }
}

extension NamedBehavior {
    func refreshNamedBehavior() {
        //print("^^^^\(behaviorTarget?.name)")
        
        nameLabel.text =!= TargetBehaviorType.prefix.stringByAppendingString(behaviorTarget?.name ?? "")
        
    }
}