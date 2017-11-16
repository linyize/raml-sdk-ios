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
    @objc optional func updatePage(_ index: Int, count: Int) -> Void
    @objc optional func willLoadContent() -> Void
    @objc optional func didLoadContent() -> Void
    @objc optional func tapPic(_ imageURL: String?) -> Void
    @objc optional func scrollViewDidScroll(_ scrollView: UIScrollView) -> Void
}

public class RamlRenderView: UIView {
    
    public init(frame: CGRect, contentHtml:String) {
        self.contentHtml = contentHtml
        let setting = RAMLRenderSetting()
        self.dataProvider = DetailRamlContentDataProvider(setting: setting)
        self.setting = setting
        self.pageIndex = 0
        self.pageArray = Array()
        super.init(frame: frame)
        setup()
        loadContent()
    }
    
    public init(frame: CGRect, contentHtml:String, setting:RAMLRenderSetting) {
        self.contentHtml = contentHtml         
        self.setting = setting
        self.dataProvider = DetailRamlContentDataProvider(setting: setting)
        self.pageIndex = 0
        self.pageArray = Array()
        super.init(frame: frame)
        setup()
        loadContent()
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
        var calcHeight: CGFloat = 0
        var page : Int = 1
        var begin : Int = 0
        var end : Int = -1
        let count = dataProvider.numberOfNode()
        for i in 0 ... (count - 1) {
            let node = dataProvider.node(atIndexPath: i)
            let nodeHeight = node?.contentSize.height ?? 0
            calcHeight += nodeHeight
            if calcHeight > frame.size.height {
                let gap = frame.size.height - calcHeight + nodeHeight;
                let over = calcHeight - frame.size.height;
                var pageHeight = calcHeight;
                if (gap > 0 && over > 0 && gap - over > 100) {
                    begin = end + 1
                    end = i
                    calcHeight = 0
                }
                else {
                    begin = end + 1
                    end = i - 1
                    pageHeight = calcHeight - nodeHeight
                    calcHeight = nodeHeight
                }
                
                if (end >= begin) {
                    NSLog("%f %d=(%d, %d)", pageHeight, page, begin, end)
                    pageArray.append([begin, end])
                    page += 1
                }
            }
        }
        if count-1 > end {
            begin = end + 1
            end = count - 1
            if (end >= begin) {
                NSLog("%f %d=(%d, %d)", calcHeight, page, begin, end)
                pageArray.append([begin, end])
            }
        }
        
        if (self.delegate?.responds(to: #selector(RamlRenderViewDelegate.updatePage(_:count:))))! {
            self.delegate?.updatePage!(pageIndex, count: pageArray.count)
        }
    }
    
    func loadContent() {
        dataProvider.htmlParseDoneBlock = {
            [weak self] in
            
            if (self?.delegate?.responds(to: #selector(RamlRenderViewDelegate.willLoadContent)))! {
                self?.delegate?.willLoadContent!()
            }
            
            self?.collectionView.reloadData()
//            let count = self?.dataProvider.numberOfNode()
//            print("parse complete \(count)")
            
            if (self?.delegate?.responds(to: #selector(RamlRenderViewDelegate.didLoadContent)))! {
                self?.delegate?.didLoadContent!()
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
    let contentHtml:String

    public var pageIndex:Int
    public var pageArray:Array<Array<Int>>

    public var delegate:RamlRenderViewDelegate?

//    public var onLinkTappedActionBlock: ((URL) -> Void)?

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
//                    cell.onLinkTappedActionBlock = {
//                        [weak self] url in
//                        self?.onLinkTappedActionBlock?(url)
//                    }
                    return cell
                } 
            }
            else if let imageNode = node as? HtmlImageNode {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RAMLDetailImageCell", for: indexPath) as? RAMLDetailImageCell {
                    cell.config(imageNode: imageNode)
                    cell.reloadUnknowSizeBlock = {
                        [weak self] in        
                        self?.collectionView.reloadItems(at: [indexPath])
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
