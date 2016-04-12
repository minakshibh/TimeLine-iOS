//
//  SupportViewController.swift
//  Timeline
//
//  Created by Valentin Knabel on 06.09.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

import UIKit

class SupportViewController: UIViewController, UIWebViewDelegate {
    
    var activityIndicator: UIActivityIndicatorView!
    var viewActivityIndicator: UIView!
    
    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width: CGFloat = 170.0
        let height: CGFloat = 50.0
        let x = self.view.frame.width/2.0 - width/2.0
        let y = self.view.frame.height/2.0 - height/2.0
        
        self.viewActivityIndicator = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
        self.viewActivityIndicator.backgroundColor = UIColor.redNavbarColor()
        self.viewActivityIndicator.layer.cornerRadius = 10
        
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        self.activityIndicator.color = UIColor.whiteColor()
        self.activityIndicator.hidesWhenStopped = false
        
        let titleLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 170, height: 50))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "Processing..."
        
        self.viewActivityIndicator.addSubview(self.activityIndicator)
        self.viewActivityIndicator.addSubview(titleLabel)
        
        self.view.addSubview(self.viewActivityIndicator)

        // Do any additional setup after loading the view.
        let supportRequest = NSURLRequest(URL: NSURL(string: local(.SettingsStringSupportURL))!)
        webView.delegate = self
        webView.loadRequest(supportRequest)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidStartLoad(webView: UIWebView)
    {
        self.activityIndicator.startAnimating()
    }
    func webViewDidFinishLoad(webView: UIWebView)
    {
        self.activityIndicator.stopAnimating()
        self.viewActivityIndicator.removeFromSuperview()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        
        let alert = UIAlertController(title: local(.SettingInternetErrorTitle), message: local(.SettingInternetErrorMessage), preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: local(.SettinginternetErrorActionDismiss), style: .Default, handler: { _ in
            delay(0.1) {
                
                self.activityIndicator.stopAnimating()
                self.viewActivityIndicator.removeFromSuperview()
            }
        }))
        self.presentAlertController(alert)
  
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
