//
//  NetworkHelper.swift
//  Timeline
//
//  Created by Krishna-Mac on 14/06/16.
//  Copyright © 2016 Conclurer GbR. All rights reserved.
//

import Foundation
import Alamofire

class NetworkHelper {
    
    private var alamoFireManager : Alamofire.Manager!
    
    class var sharedInstance: NetworkHelper {
        struct Static {
            static var instance: NetworkHelper?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = NetworkHelper()
        }
        
        return Static.instance!
    }
    init(){
        setAFconfig()
    }
    
    func setAFconfig(){
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForResource = 4
        configuration.timeoutIntervalForRequest = 4
        alamoFireManager = Alamofire.Manager(configuration: configuration)
    }
    func cancelAllRequests() {
        print("cancelling NetworkHelper requests")
        alamoFireManager.session.invalidateAndCancel()
        setAFconfig()
    }
}