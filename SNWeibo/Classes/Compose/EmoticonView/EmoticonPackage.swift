//
//  EmoticonPackage.swift
//  Emoticon_keyboard
//
//  Created by Yue Zhou on 2/3/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

/**
 * 1. load emoticons.plist -> all emotion data -> dictionary:
    packages (dict array):
        id (emotion directory)
 
 2. Based on the url, load info.plist
 info.plist (dict):
 id (current emotion directory name)
 group_name_cn (group name)
 emoticons (dict array, all emotions):
     chs (emotion's corresponding text)
     png (emotion's image)
     code (emoji's corresponding hex)
 
 */
class EmoticonPackage: NSObject {
    /// current emotion's directory
    var id: String?
    /// group name
    var group_name_cn: String?
    /// the group's emoticon objects
    var emoticons: [Emoticon]?
    
    /// the package only needs loading once
    static let packageList: [EmoticonPackage] = EmoticonPackage.loadPackages()
    
    /**
     * Returns all groups of emoticons
     */
    private class func loadPackages() -> [EmoticonPackage] {
        var packages = [EmoticonPackage]()
        
        // create the "Recent" group
        let pk = EmoticonPackage(id: "")
        pk.group_name_cn = "Recent"
        pk.emoticons = [Emoticon]()
        pk.appendEmptyEmoticons()
        packages.append(pk)
        
        let path = Bundle.main.path(forResource: "emoticons.plist", ofType: nil, inDirectory: "Emoticons.bundle")
        // load emoticons.plist
        let dict = NSDictionary(contentsOfFile: path!)!
        let dictArray = dict["packages"] as! [[String: AnyObject]]
        
        for dict in dictArray {
            let package = EmoticonPackage(id: dict["id"] as! String)
            packages.append(package)
            package.loadEmoticons()
            package.appendEmptyEmoticons()
        }
        
        return packages
    }
    
    /**
     * Returns all emoticons of a group
     */
    func loadEmoticons() {
        let emoticonDict = NSDictionary(contentsOfFile: infoPath(fileName: "info.plist"))!
        group_name_cn = emoticonDict["group_name_cn"] as? String
        let dictArray = emoticonDict["emoticons"] as! [[String: String]]
        
        emoticons = [Emoticon]()
        var index = 0
        for dict in dictArray {
            if index == 20 {
                emoticons?.append(Emoticon(isRemoveButton: true))
                index = 0
            }
            index += 1
            emoticons?.append(Emoticon(dict: dict, id: id!))
        }
    }
    
    /**
     * append empty buttons if one page does not have 21 emoticons
     */
    func appendEmptyEmoticons() {
        let count = emoticons!.count % 21
        
        // append empty buttons
        for _ in count..<20 {
            emoticons?.append(Emoticon(isRemoveButton: false))
        }
        
        // append a "remove" button
        emoticons?.append(Emoticon(isRemoveButton: true))
    }
    
    /**
     * Add emoticons lately used to the "Recent" group
     */
    func appendEmoticons(emoticon: Emoticon) {
        if emoticon.isRemoveButton {
            return
        }
        
        let contains = emoticons!.contains(emoticon)
        if !contains {
            emoticons?.removeLast()     // delete the "Remove" button
            emoticons?.append(emoticon)
        }
        
        // sort the emoticons by their frequency of use
        var result = emoticons?.sorted(by: { (e1, e2) -> Bool in
            return e1.freq > e2.freq
        })
        
        // remove the redundant
        if !contains {
            result?.removeLast()
            result?.append(Emoticon(isRemoveButton: true))
        }
        emoticons = result
        
//        print(emoticons!.count)
    }
    
    /**
     * Returns the full path of a file
     */
    func infoPath(fileName: String) -> String {
        return (EmoticonPackage.emoticonPath().appendingPathComponent(id!) as NSString).appendingPathComponent(fileName)
    }
    
    /**
     * Emoticons.bundle's path
     */
    class func emoticonPath() -> NSString {
        return (Bundle.main.bundlePath as NSString).appendingPathComponent("Emoticons.bundle") as NSString
    }
    
    init(id: String) {
        self.id = id
    }
}


class Emoticon: NSObject {
    /// emotion's text
    var chs: String?
    /// emotion's image
    var png: String? {
        didSet {
            imagePath = (EmoticonPackage.emoticonPath().appendingPathComponent(id!) as NSString).appendingPathComponent(png!)
        }
    }
    /// emoji's corresponding hex
    var code: String? {
        didSet {
            let scanner = Scanner(string: code!)
            var result: UInt32 = 0
            scanner.scanHexInt32(&result)
            emojiStr = "\(Character(UnicodeScalar(result)!))"
        }
    }
    
    var emojiStr: String?
    
    /// current emotion's directory
    var id: String?
    
    /// emoticon image's full path
    var imagePath: String?
    
    /// mark whether it is a remove button
    var isRemoveButton: Bool = false
    
    /// the frequency of use of the current emoticon
    var freq: Int = 0
    
    init(isRemoveButton: Bool) {
        super.init()
        self.isRemoveButton = isRemoveButton
    }
    
    init(dict: [String: String], id: String) {
        super.init()
        self.id = id
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
}
