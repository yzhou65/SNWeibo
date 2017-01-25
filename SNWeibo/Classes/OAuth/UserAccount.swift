//
//  UserAccount.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/23/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit
import SVProgressHUD

// Since Swift 2.0, printing an object needs overriding its CustomStringConvertible protocol's description
class UserAccount: NSObject, NSCoding {
    
    var access_token: String?
    /// access_token's lifetime
    var expires_in: NSNumber? {
        didSet {
            expires_date = Date(timeIntervalSinceNow: expires_in!.doubleValue)
        }
    }
    
    /// access_token's expiration date
    var expires_date: Date?
    
    /// authorized user's UID
    var uid: String?
    
    /// larger profile image url
    var avatar_large: String?
    
    /// user name
    var screen_name: String?
    
    
    init(dict: [String: AnyObject]) {
        // cannot write " as! String? " because dict["xx"] may return null
//        access_token = dict["access_token"] as? String
//        expires_in = dict["expires_in"] as? NSNumber  // At init, direct assignment does not call its didSet method
//        uid = dict["uid"] as? String
        
        super.init()
        // Now expires_in's didSet method is called because super.init() is called in advance
        setValuesForKeys(dict)
    }
    
    /**
     * expires_date is not found in the dict, so setValuesForKeys requires an override of the current method to ignore expires_date
     */
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        print(key)
    }
    
    /**
     * Makes user printable. Equivalent to Java's toString() method
     */
    override var description: String {
        // defines an array of member variables
        let properties = ["access_token", "expires_in", "uid", "expires_date", "avatar_large", "screen_name"]
        let dict = self.dictionaryWithValues(forKeys: properties)
        return "\(dict)"
    }
    
    func loadUserInfo(completed: @escaping (_ account: UserAccount?, _ error: Error?)->()) {
        assert(access_token != nil, "Unauthorized")
        
        let path = "2/users/show.json"
        let params = ["access_token": access_token!, "uid": uid!]
        NetworkTools.sharedNetworkTools().get(path, parameters: params, progress: nil, success: { (_, json) in
            // if successfully accessing the user account info
            if let dict = json as? [String: AnyObject] {
                self.screen_name = dict["screen_name"] as? String
                self.avatar_large = dict["avatar_large"] as? String
                
                completed(self, nil)    // archive the account
                return
            }
            
            completed(nil, nil) // show errors
            
        }) { (_, error) in
            print(error)
            completed(nil, error)
        }
    }
    
    /**
     * Returns whether user already logged in
     */
    class func userLogin() -> Bool {
        return UserAccount.unarchiveAccount() != nil
    }
    
    // MARK: save and load
    static let filePath = "account.plist".cacheDir()
    
    /**
     * Saves the authorization
     */
    func archiveAccount() {
//        print("filePath = " + UserAccount.filePath)
        NSKeyedArchiver.archiveRootObject(self, toFile: UserAccount.filePath)
    }
    
    static var account: UserAccount?
    /**
     * Loads the authorization
     */
    class func unarchiveAccount() -> UserAccount? {
        // checks whether the authorization is already loaded. No need to load it every time the app starts
        if account != nil {
            return account
        }
        
        // load the authorization
        account = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? UserAccount
        
        // checks expiration
        if account?.expires_date?.compare(Date()) == ComparisonResult.orderedAscending {    // if expired
            print("Account authorization expired")
            return nil
        }
        
        return account
    }
    
    // MARK: - NSCoding
    /**
     * Write the object to a file
     */
    func encode(with aCoder: NSCoder) {
        aCoder.encode(access_token, forKey: "access_token")
        aCoder.encode(expires_in, forKey: "expires_in")
        aCoder.encode(uid, forKey: "uid")
        aCoder.encode(expires_date, forKey: "expires_date")
        aCoder.encode(screen_name, forKey: "screen_name")
        aCoder.encode(avatar_large, forKey: "avatar_large")
    }
    
    required init?(coder aDecoder: NSCoder) {
        access_token = aDecoder.decodeObject(forKey: "access_token") as? String
        expires_in = aDecoder.decodeObject(forKey: "expires_in") as? NSNumber
        uid = aDecoder.decodeObject(forKey: "uid") as? String
        expires_date = aDecoder.decodeObject(forKey: "expires_date") as? Date
        screen_name = aDecoder.decodeObject(forKey: "screen_name") as? String
        avatar_large = aDecoder.decodeObject(forKey: "avatar_large") as? String
    }
}
