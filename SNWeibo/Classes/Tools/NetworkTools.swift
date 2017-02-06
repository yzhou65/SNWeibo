//
//  NetworkTools.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/23/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit
import AFNetworking
import SVProgressHUD

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
    
    /**
     * Send a status
     
     :params: text            the text content to be sent
     :params: image           the image content to be sent
     :params: successCallback the callback of successful delivery
     :params: failureCallback the callback of failed delivery
     */
    func sendStatus(text: String, image: UIImage?, successCallback: @escaping (_ status: Status)->(), failureCallback: @escaping (_ error: Error)->()) {
        //base path and params
        var path = "2/statuses/"
        let params = ["access_token": UserAccount.unarchiveAccount()!.access_token!, "status": text]
        
        if image != nil {
            // send a status with pictures/photos
            path += "upload.json"
            post(path, parameters: params, constructingBodyWith: { (formData) in
                
                // image -> data
                let data = UIImagePNGRepresentation(image!)!
                /**
                 * fileData: binary data from what is to be uploaded
                 * name: server-end name
                 * fileName: mostly can be randomly named
                 * mimeType: "application/octet-stream" usually
                 */
                formData.appendPart(withFileData: data, name: "pic", fileName: "abc.png", mimeType: "application/octet-stream")
                
            }, progress: nil, success: { (_, json) in
                
                successCallback(Status(dict: json as! [String: AnyObject]))
                
            }, failure: { (_, error) in
                
                failureCallback(error)
            })
        }
        else {
            // send a normal status
            path += "update.json"
            post(path, parameters: params, progress: nil, success: { (_, json) in
                successCallback(Status(dict: json as! [String: AnyObject]))
                
            }) { (_, error) in
                
                failureCallback(error)
            }
        }
    }
    
}
