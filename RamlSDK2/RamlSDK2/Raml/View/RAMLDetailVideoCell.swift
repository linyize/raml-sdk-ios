//
//  RAMLDetailVideoCell.swift
//  RamlExample
//
//  Created by ChenHeng on 10/08/2017.
//  Copyright © 2017 qingmang. All rights reserved.
//

import UIKit
import SDWebImage


class RAMLDetailVideoCell: UICollectionViewCell {
    
    var multimediaNode:HtmlMultimediaNode?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        addSubview(imageView)
        addSubview(playButton)     
    }
    
    func config(multimediaNode:HtmlMultimediaNode) {
        self.multimediaNode = multimediaNode
        
        if let urlStr = multimediaNode.coverImageURL, let url = URL(string:urlStr){
            
            let bundle = Bundle(for: RAMLDetailImageCell.self)
            let placeholder = UIImage(named: "placeholder", in: bundle, compatibleWith: nil)
            
            //imageView.sd_setShowActivityIndicatorView(true)
            imageView.contentMode = .center
            imageView.sd_setImage(with: url, placeholderImage: placeholder, options: .highPriority, completed: {[weak self] (image, error, type, url) in
                if let strongifySelf = self {
                    strongifySelf.imageView.contentMode = .scaleAspectFill
                }
            })
        }
        imageView.frame = CGRect(x: 0, y: multimediaNode.top, width: self.bounds.size.width, height: multimediaNode.contentHeight)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(x: 0, y: (self.multimediaNode?.top)!, width: self.bounds.size.width, height: (self.multimediaNode?.contentHeight)!)
        playButton.frame = self.bounds
    }
    
    //Action
    func SELTapPlayButtonAction() {
        if let urlStr = self.multimediaNode?.videoURL{
            playBlock?(urlStr)
        }
    }
    
    //Other
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Property
    var playBlock:((String) -> Void)?
    lazy var playButton:UIButton = {
        let button = UIButton(type: UIButtonType.custom)
        let bundle = Bundle(for: RAMLDetailVideoCell.self)
        let image = UIImage(named: "video_player", in: bundle, compatibleWith: nil)
        button.setImage(image, for: UIControlState.normal)
        button.frame = self.bounds
        button.alpha = 0.7
        button.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        button.addTarget(self, action: #selector(SELTapPlayButtonAction), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    lazy var imageView:FLAnimatedImageView = {
        return FLAnimatedImageView()
    }()
}
