//
//  HtmlTextNode.swift
//  RamlExample
//
//  Created by ChenHeng on 08/08/2017.
//  Copyright © 2017 qingmang. All rights reserved.
//

import UIKit

class HtmlTextListNode: NSObject {
    var type:String = ""
    var level = 0
    var order = 0
}

class HtmlTextNode: HtmlNode {
    var isBlockquote = false
    var isListTag = false
    var isTabTag = false
    var isHeading = false
    var isImageSubTitle = false

    var orderListIndex = 0
    var isOrderList = false
    var isUnOrderList = false    
    var listIndentLevel = 0
    var listNode:HtmlTextListNode?
    
    var imageAttachArray = [InnerLineImageAttachment]()
    
    var shouldAlignCenter = false
    
    var contentString:NSMutableAttributedString?
    
    public func split(_ over: CGFloat, width contentMaxWidth: CGFloat) -> HtmlTextNode! {
        if let str = contentString {
            let len = str.length
            let targetHeight = contentHeight + top + bottom - over;
            var i:Int = len-1
            var calcHeight:CGFloat = contentHeight + top + bottom
            while calcHeight > targetHeight {
                i -= 1
                if (i == 0) {
                    NSLog("cannot split %@", str.string)
                    return nil
                }
                let oldString = str.attributedSubstring(from: NSMakeRange(0, i))
                let size = self.sizeOfText(NSMutableAttributedString(attributedString: oldString), width: contentMaxWidth)
                calcHeight = size.height + top + bottom
            }
            
            NSLog("%d split %@", i, str.string)
            
            let newlen = len - i
            let newString = str.attributedSubstring(from: NSMakeRange(i, newlen))
            
            let newNode = HtmlTextNode()
            newNode.contentString = NSMutableAttributedString(attributedString: newString)
            newNode.textLeftPadding = textLeftPadding
            newNode.textRightPadding = textRightPadding
            newNode.top = top
            newNode.bottom = bottom
            newNode.shouldAlignCenter = shouldAlignCenter
            newNode.isBlockquote = isBlockquote
            newNode.isListTag = isListTag
            newNode.isTabTag = isTabTag
            newNode.isHeading = isHeading
            newNode.isImageSubTitle = isImageSubTitle
            
            let size = newNode.sizeOfTextNode(contentMaxWidth)
            newNode.contentHeight = size.height
            newNode.contentWidth = contentWidth
            
            contentString = NSMutableAttributedString(attributedString: str.attributedSubstring(from: NSMakeRange(0, i)))
            let size2 = self.sizeOfTextNode(contentMaxWidth)
            contentHeight = size2.height
            return newNode
        }
        return nil
    }
    
    public func sizeOfTextNode(_ contentMaxWidth: CGFloat) -> CGSize {
        if let str = contentString {
            return self.sizeOfText(str, width: contentMaxWidth)
        }
        return .zero
    }
    
    func sizeOfText(_ text:NSMutableAttributedString, width contentMaxWidth: CGFloat) -> CGSize {
        let maxWidth = contentMaxWidth - textLeftPadding - textRightPadding
        let bounds = text.boundingRect(with: CGSize(width:maxWidth, height:1000000), options: [.usesLineFragmentOrigin,.usesFontLeading], context: nil)
        return bounds.size
    }
}
