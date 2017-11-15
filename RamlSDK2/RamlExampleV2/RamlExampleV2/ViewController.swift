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
                let view = RamlRenderView(frame: self.view.bounds, 
                                          contentHtml: contentHtml, 
                                          setting:setting)
                view.delegate = self
                view.viewController = self
                self.view.insertSubview(view, at: 0)
                
                self.ramlView = view
                
                view.onLinkTappedActionBlock = {
                    [weak self] url in
                    print(url)
                }
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
}

extension ViewController : RamlRenderViewDelegate {
    
    func updatePage(_ index:Int, count:Int) {
        pageLabel.text = String(format: "%d/%d", index+1, count)
    }
}

