//
//  HtmlImageNode.swift
//  RamlExample
//
//  Created by ChenHeng on 08/08/2017.
//  Copyright © 2017 qingmang. All rights reserved.
//

import UIKit
import SDWebImage

class HtmlImageNode: HtmlNode {
    var imageURL:String?
    var imageWidth:CGFloat = 0
    var imageHeight:CGFloat = 0
    var isUnknownSize = false
    var titleTextNode:HtmlTextNode?
    
    override var rowHeight:CGFloat {
        get {
            let url = URL(string:self.imageURL!)
            let cacheKey = SDWebImageManager.shared().cacheKey(for: url)
            let cachedImage = SDImageCache.shared().imageFromCache(forKey: cacheKey)
            if (cachedImage != nil) {
                self.isUnknownSize = false
                self.imageWidth = self.contentWidth
                self.imageHeight = (cachedImage?.size.height ?? 200) * (self.imageWidth/(cachedImage?.size.width ?? 200))
                self.contentHeight = self.imageHeight
            }
            return self.contentHeight + self.top + self.bottom
        }
    }
}
