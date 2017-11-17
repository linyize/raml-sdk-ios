//
//  ViewController.swift
//  RamlExampleV2
//
//  Created by ChenHeng on 11/08/2017.
//  Copyright © 2017 qingmang. All rights reserved.
//

import UIKit
import RamlSDK2
import SwiftyJSON

class ViewController: UIViewController {
    @IBOutlet weak var pageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let path = Bundle.main.path(forResource: "article7", ofType: "json") {
            do {
                let str = try String(contentsOfFile: path)
                let json = JSON(parseJSON:str)
                let articleJson = json["article"]
                let contentHtml = articleJson["contentHtml"].stringValue
                let setting = RAMLRenderSetting()
                setting.fontColor = .black
                setting.fontSize = 16
                let view = RamlRenderView(frame: CGRect(x:0,y:64,width:self.view.bounds.size.width,height:self.view.bounds.size.height-64-49),
                                          contentHtml: contentHtml, 
                                          setting:setting)
                view.delegate = self
                view.viewController = self
                self.view.insertSubview(view, at: 0)
                
                self.ramlView = view
            } catch {
                
            }
        }
    }
    
    @IBAction func next(_ sender: Any) {
        ramlView.next()
    }
    
    @IBAction func prev(_ sender: Any) {
        ramlView.prev()
    }
    
    var ramlView:RamlRenderView!
    
    var loading = false
}

extension ViewController : RamlRenderViewDelegate {
    
    func willLoadContent(_ view: UIView!) {
        ramlView.calcPage()
    }
    
    func updatePage(_ index:Int, count:Int) {
        pageLabel.text = String(format: "%d/%d", index+1, count)
    }
    
    func updateImageSize(_ view: UIView!) {
        NSLog("updateImageSize")
        
        if loading {
            return
        }
        loading = true
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            NSLog("calcPage again")
            self.ramlView.calcPage()
            self.ramlView.collectionView.reloadData()
            self.loading = false
        }
    }
}

