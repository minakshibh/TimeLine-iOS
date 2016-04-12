//
//  PendingInAppViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 01.09.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

class PendingInAppViewController: UIViewController {

    var productIdentifier: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        // Do any additional setup after loading the view.
        switch productIdentifier {
        case String.additionalTimelineProduct:
            addAdditionalTimeline()
        default:
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func success() {
        self.dismissViewControllerAnimated(true) { }
    }
    
    private func failure(error: String?) {
        if let error = error {
            let alert = UIAlertController(title: local(LocalizedString.TimelineAlertLimitErrorTitle),
                message: error,
                preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: local(LocalizedString.TimelineAlertLimitErrorActionDismiss),
                style: UIAlertActionStyle.Default, handler: { _ in
//                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.navigationController?.popViewControllerAnimated(true)
            }))
            self.presentAlertController(alert)
        }
        let alert = UIAlertController(title: local(LocalizedString.TimelineAlertLimitErrorTitle),
            message: local(LocalizedString.TimelineAlertLimitErrorDefault),
            preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: local(LocalizedString.TimelineAlertLimitErrorActionLater),
            style: UIAlertActionStyle.Cancel,
            handler: { _ in
//                self.dismissViewControllerAnimated(true, completion: nil)
                self.navigationController?.popViewControllerAnimated(true)
        }))
        alert.addAction(UIAlertAction(title: local(LocalizedString.TimelineAlertLimitErrorActionRetry),
            style: UIAlertActionStyle.Default,
            handler: { _ in
                self.updateAdditionalTimeline()
        }))
        self.presentAlertController(alert)
    }
    
    func addAdditionalTimeline() {
        Storage.session.payProduct(String.additionalTimelineProduct, success: success, failure: failure)
    }
    
    func updateAdditionalTimeline() {
        Storage.session.updateProduct(String.additionalTimelineProduct, success: success, failure: failure)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
