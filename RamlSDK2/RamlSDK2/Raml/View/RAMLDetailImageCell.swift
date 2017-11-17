//
//  RAMLDetailImageCell.swift
//  RamlExample
//
//  Created by ChenHeng on 10/08/2017.
//  Copyright © 2017 qingmang. All rights reserved.
//

import UIKit
import SDWebImage


class RAMLDetailImageCell: UICollectionViewCell {
    var imageNode:HtmlImageNode?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        contentView.addSubview(imageView)
        contentView.backgroundColor = UIColor.clear;
    }
    
    func config(imageNode:HtmlImageNode) {
        self.imageNode = imageNode        
        if let urlStr = imageNode.imageURL, let url = URL(string:urlStr){
            imageView.sd_setShowActivityIndicatorView(true)
            if imageNode.isUnknownSize {
                let cacheKey = SDWebImageManager.shared().cacheKey(for: url)
                let cachedImage = SDImageCache.shared().imageFromCache(forKey: cacheKey)
                if (cachedImage != nil) {
                    imageView.image = cachedImage
                    imageNode.isUnknownSize = false
                    imageNode.imageWidth = imageNode.contentWidth
                    imageNode.imageHeight = (cachedImage?.size.height ?? 200) * (imageNode.imageWidth/(cachedImage?.size.width ?? 200))
                    imageNode.contentHeight = imageNode.imageHeight
                }
                else {
                    let bundle = Bundle(for: RAMLDetailImageCell.self)
                    let placeholder = UIImage(named: "placeholder", in: bundle, compatibleWith: nil)
                    imageView.sd_setImage(with: url, placeholderImage: placeholder, options: .highPriority, completed: {[weak self, unowned imageNode] (image, error, type, url) in
                        if let image = image, let strongifySelf = self {
                            imageNode.isUnknownSize = false
                            imageNode.imageWidth = imageNode.contentWidth
                            imageNode.imageHeight = image.size.height * (imageNode.imageWidth/image.size.width)
                            imageNode.contentHeight = imageNode.imageHeight
                            NSLog("%f", imageNode.contentHeight)
                            strongifySelf.reloadUnknowSizeBlock?()
                        }
                    })
                }
            }
            else {
                imageView.sd_setImage(with: url)
            }
            
        }
        imageView.frame = CGRect(x: 0, y: imageNode.top, width: self.bounds.size.width, height: imageNode.contentHeight)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(x: 0, y: (self.imageNode?.top)!, width: self.bounds.size.width, height: (self.imageNode?.contentHeight)!)
    }
    
    //Other
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Property
    lazy var imageView:FLAnimatedImageView = {
        return FLAnimatedImageView()
    }()
    
    var isUnknowSize = false
    var reloadUnknowSizeBlock:(()->())?
}
