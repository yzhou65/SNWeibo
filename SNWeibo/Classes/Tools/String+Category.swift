//
//  String+Category.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/24/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

extension String {
    /**
     * Embed the user string into a cache path
     */
    func cacheDir() -> String {
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last! as NSString
        return path.appending("/" + (self as NSString).lastPathComponent)
    }
    
    /**
     * Embed the user string into a doc path
     */
    func docDir() -> String {
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last! as NSString
        return path.appending("/" + (self as NSString).lastPathComponent)
    }
    
    /**
     * Embed the user string into a tmp path
     */
    func tmpDir() -> String {
        let path = NSTemporaryDirectory() as NSString
        return path.appending("/" + (self as NSString).lastPathComponent)
    }
    
}


