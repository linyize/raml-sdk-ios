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

@objc public protocol RamlRenderViewDelegate : NSObjectProtocol {
    @objc optional func updateImageSize(_ view: UIView!) -> Void
    @objc optional func updatePage(_ index: Int, count: Int) -> Void
    @objc optional func willLoadContent(_ view: UIView!) -> Void
    @objc optional func didLoadContent(_ view: UIView!) -> Void
    @objc optional func tapPic(_ imageURL: String?) -> Void
    @objc optional func scrollViewDidScroll(_ scrollView: UIScrollView) -> Void
}

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
    
    public init(frame: CGRect, setting:RAMLRenderSetting) {
        self.setting = setting
        self.dataProvider = DetailRamlContentDataProvider(setting: setting)
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
//        if #available(iOS 11.0, *) {
//            collectionView.contentInsetAdjustmentBehavior = .never
//        } else {
//            // Fallback on earlier versions
//        }
        addSubview(collectionView)
        collectionView.backgroundColor = setting.backgroundColor
        collectionView.register(RAMLDetailTextCell.self, forCellWithReuseIdentifier: "RAMLDetailTextCell")
        collectionView.register(RAMLDetailImageCell.self, forCellWithReuseIdentifier: "RAMLDetailImageCell")
        collectionView.register(RAMLDetailVideoCell.self, forCellWithReuseIdentifier: "RAMLDetailVideoCell")
        collectionView.register(RAMLDetailAudioCell.self, forCellWithReuseIdentifier: "RAMLDetailAudioCell")
        collectionView.dataSource = self    
        collectionView.delegate = self
    }
    
    public func next() {
        if pageIndex + 1 < pageArray.count {
            pageIndex += 1
            self.collectionView.reloadData()
            
            if (self.delegate?.responds(to: #selector(RamlRenderViewDelegate.updatePage(_:count:))))! {
                self.delegate?.updatePage!(pageIndex, count: pageArray.count)
            }
        }
    }
    
    public func prev() {
        if pageIndex > 0 {
            pageIndex -= 1
            self.collectionView.reloadData()
            
            if (self.delegate?.responds(to: #selector(RamlRenderViewDelegate.updatePage(_:count:))))! {
                self.delegate?.updatePage!(pageIndex, count: pageArray.count)
            }
        }
    }
    
    public func calcPage() {
        pageArray = dataProvider.calcPage(frame.size.height, pageArray: pageArray)
        nodeArray = dataProvider.contentNodeArray
        
        if (self.delegate?.responds(to: #selector(RamlRenderViewDelegate.updatePage(_:count:))))! {
            self.delegate?.updatePage!(pageIndex, count: pageArray.count)
        }
    }
    
    public func loadContent() {
        dataProvider.htmlParseDoneBlock = {
            [weak self] in
            
            if (self?.delegate?.responds(to: #selector(RamlRenderViewDelegate.willLoadContent)))! {
                self?.delegate?.willLoadContent!(self!)
            }
            
            self?.collectionView.reloadData()
            
            if (self?.delegate?.responds(to: #selector(RamlRenderViewDelegate.didLoadContent)))! {
                self?.delegate?.didLoadContent!(self!)
            }
        }        
        dataProvider.parseModel(contentHtml: self.contentHtml, async: true)
    }
    
    public func loadContentNodeArray(_ nodeArray:[HtmlNode]) {
        dataProvider.contentNodeArray = nodeArray
            
        if (self.delegate?.responds(to: #selector(RamlRenderViewDelegate.willLoadContent)))! {
            self.delegate?.willLoadContent!(self)
        }
        
        self.collectionView.contentOffset = .zero
        self.collectionView.reloadData()
        
        if (self.delegate?.responds(to: #selector(RamlRenderViewDelegate.didLoadContent)))! {
            self.delegate?.didLoadContent!(self)
        }
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
    public lazy var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = .flexibleHeight
        return collectionView 
    }()
    var setting:RAMLRenderSetting
    let dataProvider:DetailRamlContentDataProvider
    
    public var contentHtml:String = ""

    public var pageIndex:Int = 0
    public var pageArray:Array<Array<Int>> = []
    public var nodeArray:[HtmlNode] = []

    public var delegate:RamlRenderViewDelegate?
    public var viewController:UIViewController?
}

extension RamlRenderView : UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if pageIndex < pageArray.count {
            let range = pageArray[pageIndex]
            return range[1] - range[0] + 1
        }
        return dataProvider.numberOfNode()
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var realIndex = indexPath.row
        if pageIndex < pageArray.count {
            let range = pageArray[pageIndex]
            realIndex = range[0] + indexPath.row
        }
        if let node = dataProvider.node(atIndexPath: realIndex) {
            if let textNode = node as? HtmlTextNode {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RAMLDetailTextCell", for: indexPath) as? RAMLDetailTextCell {
                    cell.config(textNode: textNode)
                    return cell
                } 
            }
            else if let imageNode = node as? HtmlImageNode {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RAMLDetailImageCell", for: indexPath) as? RAMLDetailImageCell {
                    cell.config(imageNode: imageNode)
                    cell.reloadUnknowSizeBlock = {
                        [weak self] in
                        
                        if self?.pageArray.count == 0 {
                            self?.collectionView.reloadItems(at: [indexPath])
                        }
                        
                        if (self?.delegate?.responds(to: #selector(RamlRenderViewDelegate.updateImageSize(_:))))! {
                            self?.delegate?.updateImageSize!(self)
                        }
                    }
                    return cell
                }
            }
            else if let multimediaNode = node as? HtmlMultimediaNode {
                if multimediaNode.isAudio {
                    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RAMLDetailAudioCell", for: indexPath) as? RAMLDetailAudioCell {
                        cell.config(multimediaNode: multimediaNode)
                        cell.playBlock = {
                            [weak self] str in
                            self?.showMediaPlayer(urlStr: str)
                        }
                        return cell
                    }
                }
                else {
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
        var realIndex = indexPath.row
        if pageIndex < pageArray.count {
            let range = pageArray[pageIndex]
            realIndex = range[0] + indexPath.row
        }
        
        if let node = dataProvider.node(atIndexPath: realIndex) {
            if node.contentSize.width > 0 {
                return node.contentSize
            }            
        }
        return CGSize(width: self.frame.size.width, height: 100)
    }
}

extension RamlRenderView : UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var realIndex = indexPath.row
        if pageIndex < pageArray.count {
            let range = pageArray[pageIndex]
            realIndex = range[0] + indexPath.row
        }
        
        if let node = dataProvider.node(atIndexPath: realIndex) {
            if node.isKind(of: HtmlImageNode.classForCoder()) {
                let imageNode = node as! HtmlImageNode
                if (self.delegate?.responds(to: #selector(RamlRenderViewDelegate.tapPic(_:))))! {
                    self.delegate?.tapPic!(imageNode.imageURL)
                }
            }
        }
    }
}

extension RamlRenderView : UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.delegate?.responds(to: #selector(RamlRenderViewDelegate.scrollViewDidScroll(_:))))! {
            self.delegate?.scrollViewDidScroll!(scrollView)
        }
    }
}
