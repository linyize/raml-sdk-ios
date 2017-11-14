//
//  RamlRenderView.swift
//  RamlExample
//
//  Created by ChenHeng on 10/08/2017.
//  Copyright © 2017 qingmang. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

public class RamlRenderView: UIView {
    
    public init(frame: CGRect, contentHtml:String) {
        self.contentHtml = contentHtml
        let setting = RAMLRenderSetting()
        self.dataProvider = DetailRamlContentDataProvider(setting: setting)
        self.setting = setting
        super.init(frame: frame)
        setup()
        loadContent()
    }
    
    public init(frame: CGRect, contentHtml:String, setting:RAMLRenderSetting) {
        self.contentHtml = contentHtml         
        self.setting = setting
        self.dataProvider = DetailRamlContentDataProvider(setting: setting)
        super.init(frame: frame)
        setup()
        loadContent()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        addSubview(collectionView)
        collectionView.backgroundColor = setting.backgroundColor
        collectionView.register(RAMLDetailTextCell.self, forCellWithReuseIdentifier: "RAMLDetailTextCell")
        collectionView.register(RAMLDetailImageCell.self, forCellWithReuseIdentifier: "RAMLDetailImageCell")
        collectionView.register(RAMLDetailVideoCell.self, forCellWithReuseIdentifier: "RAMLDetailVideoCell")
        collectionView.register(RAMLDetailAudioCell.self, forCellWithReuseIdentifier: "RAMLDetailAudioCell")
        collectionView.dataSource = self    
        collectionView.delegate = self
    }
    
    func loadContent() {
        dataProvider.htmlParseDoneBlock = {
            [weak self] in            
            self?.collectionView.reloadData()
//            let count = self?.dataProvider.numberOfNode()
//            print("parse complete \(count)")
            
            if (self?.viewController != nil) && (self?.viewController?.responds(to: Selector(("didLoadContent"))))! {
                self?.viewController?.perform(Selector(("didLoadContent")))
            }
        }        
        dataProvider.parseModel(contentHtml: self.contentHtml, async: true)
    }
    
    //Action support
    func showMediaPlayer(urlStr:String) {
        guard let url = URL(string:urlStr) else {
            return
        }
        let player = AVPlayer(url: url)
        let playerController = AVPlayerViewController()
        playerController.player = player        
        viewController?.present(playerController, animated: true) {
            player.play()
        }
    }
 
    //Other
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

    //Property
    lazy var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = .flexibleHeight
        return collectionView 
    }()
    var setting:RAMLRenderSetting
    let dataProvider:DetailRamlContentDataProvider
    let contentHtml:String
    
    public var viewController:UIViewController?
}

extension RamlRenderView : UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataProvider.numberOfNode()
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let node = dataProvider.node(atIndexPath: indexPath.row) {
            if let textNode = node as? HtmlTextNode {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RAMLDetailTextCell", for: indexPath) as? RAMLDetailTextCell {
                    cell.config(textNode: textNode)
                    return cell
                } 
            }else if let imageNode = node as? HtmlImageNode {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RAMLDetailImageCell", for: indexPath) as? RAMLDetailImageCell {
                    cell.config(imageNode: imageNode)
                    cell.reloadUnknowSizeBlock = {
                        [weak self] in        
                        self?.collectionView.reloadItems(at: [indexPath])         
                    }
                    return cell
                }
            }else if let multimediaNode = node as? HtmlMultimediaNode {
                if multimediaNode.isAudio {
                    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RAMLDetailAudioCell", for: indexPath) as? RAMLDetailAudioCell {
                        cell.config(multimediaNode: multimediaNode)
                        cell.playBlock = {
                            [weak self] str in
                            self?.showMediaPlayer(urlStr: str)
                        }
                        return cell
                    }
                }else {
                    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RAMLDetailVideoCell", for: indexPath) as? RAMLDetailVideoCell {
                        cell.config(multimediaNode: multimediaNode)
                        cell.playBlock = {
                            [weak self] str in
                            self?.showMediaPlayer(urlStr: str)
                        }
                        return cell
                    }
                }
                
            }          
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RAMLDetailTextCell", for: indexPath)
        return cell
    }    
}

extension RamlRenderView : UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let node = dataProvider.node(atIndexPath: indexPath.row) {
            if node.contentSize.width > 0 {
                return node.contentSize
            }            
        }
        return CGSize(width: self.frame.size.width, height: 100)
    }
}

extension RamlRenderView : UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let node = dataProvider.node(atIndexPath: indexPath.row) {
            if node.isKind(of: HtmlImageNode.classForCoder()) {
                let imageNode = node as! HtmlImageNode
                if (self.viewController != nil) && (self.viewController?.responds(to: Selector("tapPic:")))! {
                    self.viewController?.perform(Selector("tapPic:"), with: imageNode.imageURL)
                }
            }
        }
        
    }
}

extension RamlRenderView : UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.viewController != nil) && (self.viewController?.responds(to: Selector("scrollViewDidScroll:")))! {
            self.viewController?.perform(Selector("scrollViewDidScroll:"), with: scrollView)
        }
    }
}
