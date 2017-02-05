//
//  UITextView+Category.swift
//  Emoticon_keyboard
//
//  Created by Yue Zhou on 2/4/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

extension UITextView {
    func insertEmoticon(emoticon: Emoticon) {
        // for the "Remove" button
        if emoticon.isRemoveButton {
            deleteBackward()
        }
        
        if emoticon.emojiStr != nil {
            self.replace(self.selectedTextRange!, withText: emoticon.emojiStr!)
        }
        
        // whether it is emoticon image
        if emoticon.png != nil {
            // create the attachment of an NSAttributedString
//                        let s = self.customTextView.font!.lineHeight
//                        print(s)
            
            let imageText = EmoticonTextAttachment.imageText(emoticon: emoticon, font: font!)
            
            // insert emoticons
            let strM = NSMutableAttributedString(attributedString: self.attributedText)
            let range = self.selectedRange   // cursor location
            strM.replaceCharacters(in: range, with: imageText)
            
            // set the attributed text's font, otherwise every time inserting a default emoticon, the following emoji or string's font will be smaller
            strM.addAttribute(NSFontAttributeName, value: font!, range: NSRange(location: range.location, length: 1))
            
            // set the replaced strM back to the textView's attributedText
            self.attributedText = strM
            
            // restore the cursor's previous location
            self.selectedRange = NSMakeRange(range.location + 1, 0)
            
            // voluntarily call textViewDidChange so that the placeholderLabel will be hidden
            delegate?.textViewDidChange!(self)
        }
    }
    
    /**
     * Returns the string to be sent to the server
     */
    func emoticonAttributdText() -> String {
        var strM: String = ""
        
        // get the content to be sent to server
        attributedText.enumerateAttributes(in: NSMakeRange(0, self.attributedText.length), options: NSAttributedString.EnumerationOptions.init(rawValue: 0)) { (objc, range, _) in
            //            print(objc)
            //            print("range: \(range)")
            //            let res = (self.customTextView.text as NSString).substring(with: range)
            //            print(res)
            
            if objc["NSAttachment"] != nil {
                let attachment = objc["NSAttachment"] as! EmoticonTextAttachment
                strM += attachment.chs!
            } else {
                strM += (self.text as NSString).substring(with: range)
            }
        }
        return strM
    }
}
