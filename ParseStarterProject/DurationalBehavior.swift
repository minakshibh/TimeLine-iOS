//
//  DurationalBehavior.swift
//  Timeline
//
//  Created by Valentin Knabel on 08.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

protocol DurationalBehavior {
    typealias TargetBehaviorType: Durational
    var behaviorTarget: TargetBehaviorType? { get }
    var durationLabel: UILabel! { get }
}

extension DurationalBehavior {
    func refreshDurationalBehavior() {
        durationLabel.text =!= behaviorTarget.flatMap { String($0.duration) }
    }
}
