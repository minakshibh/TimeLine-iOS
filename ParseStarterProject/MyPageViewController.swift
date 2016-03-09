//
//  MyPageViewController.swift
//  Timeline
//
//  Created by Krishna Mac Mini 2 on 09/03/16.
//  Copyright © 2016 Conclurer GbR. All rights reserved.
//

import UIKit

class MyPageViewController: UIPageViewController,UIPageViewControllerDataSource,UIPageViewControllerDelegate  {
    var pages = [UIViewController]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        
        let page1: UIViewController! = storyboard?.instantiateViewControllerWithIdentifier("Left")
        let page2: UIViewController! = storyboard?.instantiateViewControllerWithIdentifier("Capture")
        let page3: UIViewController! = storyboard?.instantiateViewControllerWithIdentifier("Right")
        
        
        
        pages.append(page1)
        pages.append(page2)
        pages.append(page3)
        
        
        setViewControllers([page2], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "update", userInfo: nil, repeats: false)
        
        for value in view.subviews {
            if let scrollView = value as? UIScrollView {
                scrollView.bounces = false
                
            }
        }
//        self.automaticallyAdjustsScrollViewInsets = false
    }
    override func viewWillAppear(animated: Bool) {
        
    }
    func update(){
//        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+1)
    }
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.indexOf(viewController)!
        let previousIndex = abs((currentIndex - 1) % pages.count)
        
        if(currentIndex <= 0){
            return nil
        }
        
        // Setting up the new view's frame
//        var newVC = self.viewControllerAtIndex(currentIndex)
//        newVC.view.frame = self.pageViewController.view.bounds
//        return newVC
        
        return pages[previousIndex]
        
        
        
        
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.indexOf(viewController)!
        let nextIndex = abs((currentIndex + 1) % pages.count)
        
        if(currentIndex >= 3){
            return nil
        }

        return pages[nextIndex]
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
   
}
