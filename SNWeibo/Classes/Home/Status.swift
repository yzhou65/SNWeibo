//
//  Status.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/25/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit
import SDWebImage

class Status: NSObject {

    /// weibo's creat time
    var created_at: String? {
        didSet {
//            print(created_at)
            /*
             Just now (within one minute)
             x minutes ago (within one hour)
             x hours ago (within one day)
             yesterday HH:mm (yesterday time)
             MM-dd HH:mm (within one year)
             yyyy-MM-dd HH:mm (earlier)
             */
            let createdDate = Date.date(with: created_at!)
            created_at = createdDate.descDate
            
//            let comps = calendar.dateComponents(Set<Calendar.Component>(.year), from: createdDate, to: Date())
        }
    }
    
    /// weibo ID
    var id: Int = 0
    
    /// weibo text
    var text: String?
    
    /// weibo source
    var source: String? {
        didSet {
            // set source. Source's format is a link: <a href="http://xxxx" rel="dsfsf">Yahoo</a>
            // extract the text content between ">" and "<"
            if let str = source {
                if str == "" {
                    return
                }
                let startLocation = (str as NSString).range(of: ">").location + 1
                let length = (str as NSString).range(of: "<", options: NSString.CompareOptions.backwards).location - startLocation
                source = "From: " + (str as NSString).substring(with: NSMakeRange(startLocation, length))
            }
        }
    }
    
    /// pictures' urls represented by dictionary array
    var pic_urls: [[String: AnyObject]]? {
        didSet {
            // initialize the array
            storedPicURLs = [URL]()
            storedLargePicURLs = [URL]()
            
            for dict in pic_urls! {
                if let urlStr = dict["thumbnail_pic"] as? String {
                    // url string -> url and saved to array
                    storedPicURLs?.append(URL(string: urlStr)!)
                    
                    // large picture
                    let largeURLStr = urlStr.replacingOccurrences(of: "thumbnail", with: "large")
                    storedLargePicURLs?.append(URL(string: largeURLStr)!)
                    
                }
            }
        }
    }
    
    /// the array of the current weibo's small pictures' urls
    var storedPicURLs: [URL]?
    
    /// the array of the current weibo's large pictures' urls
    var storedLargePicURLs: [URL]?
    
    /// user object that contains user data
    var user: User?
    
    /// a shared(forwarded) status
    var retweeted_status: Status?
    
    // if it is a forwarded status, no original picture
    /// array of original or forwarded status's picture urls. It only has getter
    var pictureURLs: [URL]? {
        return retweeted_status != nil ? retweeted_status?.storedPicURLs : storedPicURLs
    }
    
    /// array of original or forwarded status's large picture urls. It only has getter
    var largePictureURLs: [URL]? {
        return retweeted_status != nil ? retweeted_status?.storedLargePicURLs: storedLargePicURLs
    }
    
    /**
     * Loads statuses
     */
    class func loadStatuses(since_id: Int, max_id: Int, completed: @escaping (_ models: [Status]?, _ error: Error?)->()) {
        let path = "2/statuses/home_timeline.json"
        var params = ["access_token": UserAccount.unarchiveAccount()?.access_token]
        
        // pull-down to refresh
        if since_id > 0 {
            params["since_id"] = "\(since_id)"
        }
        
        // pull-up to refresh
        if max_id > 0 {
            params["max_id"] = "\(max_id - 1)"
        }
        
        // send asynchrous network request
        NetworkTools.sharedNetworkTools().get(path, parameters: params, progress: nil, success: { (_, json) in
//            print(json)
            
            // get statuses
            let dictArr = (json as! [String: AnyObject])["statuses"]
            let models = dict2Model(dictArr: dictArr as! [[String : AnyObject]])
            
            // cache the content images of a weibo status and pass the models data to caller using the "completed" closure
            cacheStatusImages(list: models, completed: completed)
            
            
        }) { (_, error) in
            print(error)
            completed(nil, error)
        }
    }
    
    /**
     * Caches the content images of a weibo status
     */
    class func cacheStatusImages(list: [Status], completed: @escaping (_ models: [Status]?, _ error: Error?)->()) {
        if list.count == 0 {
            completed(list, nil)
            return
        }
        
        // create a group. Before Swift 3.0: group = dispatch_group_create()
        let group = DispatchGroup()
        
        for status in list {
            // checks whether the current weibo status has pictures
//            if status.storedPicURLs == nil {
//                continue
//            }
            
            // equivalent to the above commented block of codes
            guard status.pictureURLs != nil else {
                continue
            }
            
            for url in status.pictureURLs! {
                // put downloading task into the group. Before Swift 3: dispatch_group_enter(group)
                group.enter()
                
                // caches pictures. Note: this step is asynchrous, so dispatch group is necessary
                SDWebImageManager.shared().downloadImage(with: url, options: SDWebImageOptions(rawValue: 0), progress: nil, completed: { (_, _, _, _, _) in
//                    print("cached")
                    group.leave()   // before Swift 3: dispatch_group_leave(group)
                })
            }
        }
        
        // once all pictures cached, notify caller with the closure
        group.notify(queue: DispatchQueue.main) {
//            print("done")
            // here all pictures must have already been cached
            completed(list, nil)
        }
        
    }
    
    /**
     * Converts the dict array to status array
     */
    class func dict2Model(dictArr: [[String: AnyObject]]) -> [Status] {
        var models = [Status]()
        for dict in dictArr {
            models.append(Status(dict: dict))   // init a Status object and append it to models
        }
        return models
    }
    
    /**
     * Initializes a status object using kvc receiving a dictionary for assigning values to member variables
     */
    init(dict: [String: AnyObject]) {
        super.init()    // allocate memory for member variables
        setValuesForKeys(dict)
    }
    
    /**
     * During the operation of "setValuesForKeys", this method is called
     * A User object can be initialized with dict data when the "user" dict within status dictArr is set values
     * In this method, several intercepting operation can be implemented
     */
    override func setValue(_ value: Any?, forKey key: String) {
        // checks whether status dictArr's "user" dict is being assigned values
        if "user" == key {
            user = User(dict: value as! [String : AnyObject])
            return
        }
        
        // checks whether it is a shared/forwarded status
        if "retweeted_status" == key {
            retweeted_status = Status(dict: value as! [String : AnyObject])
            return
        }
        super.setValue(value, forKey: key)
    }
    
    /**
     * This method is overriden to ensure that variables which are not in the dict will not affect kvc
     */
    override func setValue(_ value: Any?, forUndefinedKey key: String) { }
    
    /**
     * For printing a status object
     */
    var properties = ["create_at", "id", "text", "source", "pic_urls"]
    override var description: String {
        let dict = dictionaryWithValues(forKeys: properties)
        return "\(dict)"
    }
}
