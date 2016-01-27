//
//  WalkthroughDelegate.swift
//  Timeline
//
//  Created by Valentin Knabel on 11.09.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import Foundation

class WalkthroughDelegate: BWWalkthroughViewControllerDelegate {
    
    var master: BWWalkthroughViewController
    
    private init(walkthroughViewController: BWWalkthroughViewController) {
        self.master = walkthroughViewController
    }
    
    class func instantiateDefaultWalkthrough() -> WalkthroughDelegate {
        let stb = UIStoryboard(name: "Main", bundle: nil)
        let walkthrough = stb.instantiateViewControllerWithIdentifier("walk") as! BWWalkthroughViewController
        walkthrough.scrollview.alwaysBounceVertical = false
        walkthrough.automaticallyAdjustsScrollViewInsets = false
        let page_zero = stb.instantiateViewControllerWithIdentifier("walkCam") as! WalkthroughViewController
        let page_one = stb.instantiateViewControllerWithIdentifier("walkMom") as! WalkthroughViewController
        let page_two = stb.instantiateViewControllerWithIdentifier("walkMe")as! WalkthroughViewController
        let page_three = stb.instantiateViewControllerWithIdentifier("walkTrend") as! WalkthroughViewController
        let login = stb.instantiateViewControllerWithIdentifier("walkLogin") as! BWWalkthroughPageViewController
        
        [page_zero, page_one, page_two, page_three].each { $0.shouldHideDismissButton = true }
        
        // Attach the pages to the master
        let inst = WalkthroughDelegate(walkthroughViewController: walkthrough)
        walkthrough.delegate = inst
        walkthrough.addViewController(page_zero)
        walkthrough.addViewController(page_one)
        walkthrough.addViewController(page_two)
        walkthrough.addViewController(page_three)
        walkthrough.addViewController(login)
        return inst
    }
    
}
