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
        //UIApplication.sharedApplication().statusBarStyle = .LightContent
       
        let transitionTo = "\(NSUserDefaults.standardUserDefaults().valueForKey("transitionTo")!)"
        
        if transitionTo == "capture"{
            for(var i=0;i<3;i++){
                if(i==2){
                    self.movePages(1)
                    continue
                }
                if(i==0){
                    self.movePages(1)
                    self.movePages(0)
                    continue
                }
                if(i==1){
                    self.movePages(2)
                    continue
                }
                
            }
        }else if transitionTo == "Right"{
            for(var i=0;i<3;i++){
                if(i==2){
                    self.movePages(2)
                    continue
                }
                if(i==0){
                    self.movePages(2)
                    self.movePages(0)
                    continue
                }
                if(i==1){
                    self.movePages(1)
                    continue
                }
                
            }
        }else if transitionTo == "Left"{
            for(var i=0;i<3;i++){
                if(i==2){
                    self.movePages(0)
                    continue
                }
                if(i==0){
                    self.movePages(0)
                    self.movePages(2)
                    continue
                }
                if(i==1){
                    self.movePages(1)
                    continue
                }
                
            }
        }else {
            for(var i=0;i<3;i++){
                if(i==2){
                    self.movePages(1)
                    continue
                }
                if(i==0){
                    self.movePages(1)
                    self.movePages(2)
                    continue
                }
                if(i==1){
                    self.movePages(0)
                    continue
                }
                
            }
        }
        

    }
    
    func profileButtonClick(){
        self.rightButtonClick()
    }
     func timelineButtonCLick(){
        self.leftButtonClick()
    }
    override func viewWillAppear(animated: Bool) {
        
       
        self.view.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height)
        
//        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "update", userInfo: nil, repeats: false)
//
//        for(var i=0;i<3;i++){
//            if(i==2){
//                self.movePages(1)
//                continue
//            }
//            if(i==0){
//                self.movePages(0)
//                continue
//            }
//            if(i==1){
//                self.movePages(2)
//                continue
//            }
//            
//        }
        
    }
    func update(){
        self.movePages(2)
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
    
    
    
//    func indexOfStartingPage() -> Int {
//        return 1 // EZSwipeController starts from 2nd, green page
//    }
}
