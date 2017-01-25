//
//  NetworkTools.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/23/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit
import AFNetworking

class NetworkTools: AFHTTPSessionManager {
    static let tools: NetworkTools = {
        // note: baseURL must end with "/"
        let url = URL(string: "https://api.weibo.com/")
        let t = NetworkTools(baseURL: url)
        
        // set AFN's acceptable data type
        t.responseSerializer.acceptableContentTypes = NSSet(objects: "application/json", "text/json", "text/javascript", "text/plain") as! Set<String>
        
        return t
    }()
    
    /**
     * Returns a singleton instance of AFHTTPSessionManager
     */
    class func sharedNetworkTools() -> NetworkTools {
        return tools
    }
    
}
