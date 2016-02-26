//
//  drawer.swift
//  Timeline
//
//  Created by Krishna Mac Mini 2 on 25/02/16.
//  Copyright © 2016 Conclurer GbR. All rights reserved.
//

import UIKit

class drawer: EZSwipeController {
    override func setupView() {
        datasource = self
        navigationBarShouldNotExist = true
    }
    override func viewDidLoad() {
        self.navigationController?.navigationBarHidden = true
    }
}
extension drawer: EZSwipeControllerDataSource {
    func viewControllerData() -> [UIViewController] {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //        let redVC = storyboard.instantiateViewControllerWithIdentifier("MyTimelines")
        
        let redVC = storyboard.instantiateViewControllerWithIdentifier("Left")
        //        redVC.view.backgroundColor = UIColor.redColor()
        
        let blueVC = storyboard.instantiateViewControllerWithIdentifier("Capture")//        blueVC.view.backgroundColor = UIColor.blueColor()
        
        let greenVC = storyboard.instantiateViewControllerWithIdentifier("Right")
        //        greenVC.view.backgroundColor = UIColor.greenColor()
        
        return [redVC, blueVC, greenVC]
    }
    func indexOfStartingPage() -> Int {
        return 1 // EZSwipeController starts from 2nd, green page
    }
}