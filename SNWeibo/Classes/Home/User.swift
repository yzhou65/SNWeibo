//
//  User.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/26/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

class User: NSObject {

    var id: Int = 0
    
    var name: String?
    
    /// String representation of a user profile image url
    var profile_image_url: String? {
        didSet {
            if let urlStr = profile_image_url {
                imageURL = URL(string: urlStr)
            }
        }
    }
    
    /// URL representation of a user profile image url
    var imageURL: URL?
    
    /// whether the user is verified
    var verified: Bool = false
    
    /// verified type: -1 -> unverified, 0 -> verified, 2,3,5 -> enterprise verified, 220 -> premium
    var verified_type: Int = -1 {
        didSet {
            switch verified_type {
            case 0:
                verified_image = UIImage(named: "avatar_vip")
            case 2, 3, 5:
                verified_image = UIImage(named: "avatar_enterprise_vip")
            case 220:
                verified_image = UIImage(named: "avatar_grassroot")
            default:
                verified_image = nil
            }
        }
    }
    
    /// the user's verified image
    var verified_image: UIImage?
    
    /// membership level (note: mbrank is primitive type and should be initialized 0 instead of Int?, otherwise kvc will not set value for it)
    var mbrank: Int = 0 {
        didSet {
            if mbrank > 0 && mbrank < 7 {
                mbrank_image = UIImage(named: "common_icon_membership_level\(mbrank)")
            }
        }
    }
    
    /// image of a membership level
    var mbrank_image: UIImage?
    
    /**
     * Initializes a status object using kvc receiving a dictionary for assigning values to member variables
     */
    init(dict: [String: AnyObject]) {
        super.init()    // allocate memory for member variables
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) { }
    
    /**
     * For printing a status object
     */
    var properties = ["id", "name", "profile_image_url", "verified", "verified_type"]
    override var description: String {
        let dict = dictionaryWithValues(forKeys: properties)
        return "\(dict)"
    }

}
