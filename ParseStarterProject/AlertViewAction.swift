//
//  AlertViewAction.swift
//  Timeline
//
//  Created by Valentin Knabel on 08.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

import UIKit

extension UIAlertController {
    func addAction(title title: String?, style: UIAlertActionStyle, handler: ((UIAlertAction) -> Void)?) {
        self.addAction(UIAlertAction(title: title, style: style, handler: handler))
    }
}
