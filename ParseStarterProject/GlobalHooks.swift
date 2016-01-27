//
//  GlobalHooks.swift
//  Timeline
//
//  Created by Valentin Knabel on 05.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import ConclurerHook

extension String : RawHookKeyType { }

let delegationHook = DelegationHook<String>()
let serialHook = SerialHook<String>()
