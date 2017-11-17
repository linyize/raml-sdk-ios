//
//  RAMLDetailTextCell.swift
//  RamlExample
//
//  Created by ChenHeng on 10/08/2017.
//  Copyright © 2017 qingmang. All rights reserved.
//

import UIKit
import SDWebImage

class RAMLDetailTextCell: UICollectionViewCell {
    
    var textNode: HtmlTextNode?
    
    override init(frame: CGRect) {        
        super.init(frame: frame)        
    }
    
    func setup() {
        contentView.addSubview(textView)
        contentView.backgroundColor = .clear
    }
    
    func magazineLogo(image: UIImage) -> UIImage {
        let imageBounds = CGRect(x: 0, y: 0, width: 15, height: 15)
        UIGraphicsBeginImageContextWithOptions(imageBounds.size, false, 0)
        let path = UIBezierPath(roundedRect: imageBounds.insetBy(dx:0, dy:0), cornerRadius: 3.0)
        let context = UIGraphicsGetCurrentContext()
        context!.saveGState()
        path.addClip()
        image.draw(in: imageBounds)
        context!.restoreGState()
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return roundedImage!;
    }
    
    func checkAttachImageLoadFinish(image: UIImage, attachment: InnerLineImageAttachment) {
        guard let contentString = textNode?.contentString else {
            return
        }
        
        // magazine logo round corner
        let magazineLogo = self.magazineLogo(image: image)
        
        let range = NSRange(location: 0, length: contentString.length)
        textNode?.contentString?.enumerateAttribute(NSAttachmentAttributeName, in: range,
                                                    options: NSAttributedString.EnumerationOptions.reverse,
                                                    using: {[weak self, weak attachment] value, _, _ in
                                                        if let attach = value as? InnerLineImageAttachment, attach.imageURL == attachment?.imageURL {
                                                            attachment?.image = magazineLogo
                                                            self?.textView.setNeedsDisplay()
                                                        }
        })
    }
    
    func config(textNode: HtmlTextNode) {
        setup()
        self.textNode = textNode
        if let contentString = textNode.contentString {
            textView.attributedText = contentString
        }
        for attach in textNode.imageAttachArray {
            let urlStr = attach.imageURL
            SDWebImageManager.shared().loadImage(with: URL(string: urlStr), options: SDWebImageOptions.avoidAutoSetImage, progress: { _, _, _ in                
            }, completed: {[weak self, weak attach] image, _, _, _, _, _ in
                if let attachment = attach, let image = image {
                    self?.checkAttachImageLoadFinish(image: image, attachment: attachment)   
                }                
            })        
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let leftPadding = textNode?.textLeftPadding ?? 0
        let rightPadding = textNode?.textRightPadding ?? 0
        let top = textNode?.top ?? 0
        let bottom = textNode?.bottom ?? 0
        let maxWidth = frame.size.width - rightPadding - leftPadding
        textView.frame = CGRect(x: leftPadding, y: top, width: maxWidth, height: frame.size.height - top - bottom + 2)
    }
    
    // Other
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.contentInset = .zero
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.isScrollEnabled = false
        textView.linkTextAttributes = [NSForegroundColorAttributeName:UIColor.blue,
                                       NSUnderlineColorAttributeName:UIColor.lightGray,
                                       NSUnderlineStyleAttributeName:NSNumber(value: NSUnderlineStyle.styleSingle.rawValue)]
        return textView
    }()
}

extension RAMLDetailTextCell : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return false
    }
}
