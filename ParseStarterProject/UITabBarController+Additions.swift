//
//  UITabBarController+Additions.swift
//  Timeline
//
//  Created by Valentin Knabel on 31.07.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

public extension UITabBarController {
    
    private static var DefaultDuration: NSTimeInterval = 0.8
    private static var DefaultLeftOptions: UIViewAnimationOptions = UIViewAnimationOptions.TransitionCrossDissolve
    private static var DefaultRightOptions: UIViewAnimationOptions = UIViewAnimationOptions.TransitionCrossDissolve
    
    
    public func decreaseSelectedIndex(duration: NSTimeInterval = UITabBarController.DefaultDuration,
        leftOptions: UIViewAnimationOptions = UITabBarController.DefaultLeftOptions,
        rightOptions: UIViewAnimationOptions = UITabBarController.DefaultRightOptions,
        completion: (Bool -> Void)? = nil)
    {
        setSelectedIndex(selectedIndex-1, duration: duration, leftOptions: leftOptions, rightOptions: rightOptions, completion: completion)
    }
    
    public func increaseSelectedIndex(duration: NSTimeInterval = UITabBarController.DefaultDuration,
        leftOptions: UIViewAnimationOptions = UITabBarController.DefaultLeftOptions,
        rightOptions: UIViewAnimationOptions = UITabBarController.DefaultRightOptions,
        completion: (Bool -> Void)? = nil)
    {
        setSelectedIndex(selectedIndex+1, duration: duration, leftOptions: leftOptions, rightOptions: rightOptions, completion: completion)
    }
    
    public func setSelectedIndex(index: Int, duration: NSTimeInterval = UITabBarController.DefaultDuration,
        leftOptions: UIViewAnimationOptions = UITabBarController.DefaultLeftOptions,
        rightOptions: UIViewAnimationOptions = UITabBarController.DefaultRightOptions,
        completion: (Bool -> Void)? = nil)
    {
        if let fromView = selectedViewController?.view,
            let toViewController = viewControllers?[index],
            let toView = toViewController.view
        {
            UIView.transitionFromView(fromView,
                toView: toView,
                duration: duration,
                options: (index > selectedIndex ? leftOptions : rightOptions)) { finished in
                    if finished {
                        self.selectedIndex = index
                    }
                    completion?(finished)
            }
        }
    }
    
}

public extension UIViewController {
    
    @IBAction public func swipeToPreviousTabViewController(sender: AnyObject?) {
        self.tabBarController?.decreaseSelectedIndex()
    }
    
    @IBAction public func swipeToNextTabViewController(sender: AnyObject?) {
        self.tabBarController?.increaseSelectedIndex()
    }
    
}
