//
//  File.swift
//  Timeline
//
//  Created by Valentin Knabel on 10.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import Foundation

protocol Synchronized {
    
    var state: SynchronizationState { get set }
    
}

protocol DictConvertable {
    
    typealias ParentType = DictConvertable
    
    init(dict: [String: AnyObject], parent: ParentType?)
    
    var dict: [String: AnyObject] { get }
    var parent: ParentType? { get }
    
}