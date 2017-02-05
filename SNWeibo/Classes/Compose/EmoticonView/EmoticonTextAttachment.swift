//
//  EmoticonTextAttachment.swift
//  Emoticon_keyboard
//
//  Created by Yue Zhou on 2/4/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

class EmoticonTextAttachment: NSTextAttachment {
    /// emoticon's corresponding string
    var chs: String?
    
    /**
     * Based on emoticon object, create the emoticon string
     */
    class func imageText(emoticon: Emoticon, font: UIFont) -> NSAttributedString {
        let attachment = EmoticonTextAttachment()
        attachment.chs = emoticon.chs
        attachment.image = UIImage(contentsOfFile: emoticon.imagePath!)
        
        let s = font.lineHeight
        attachment.bounds = CGRect(x: 0, y: -4, width: s, height: s)
        return NSAttributedString(attachment: attachment)
    }
}
