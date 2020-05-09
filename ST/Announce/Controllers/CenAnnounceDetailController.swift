//
//  CenAnnounceDetailController.swift
//  ST
//
//  Created by taotao on 2019/5/27.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import UIKit
import WebKit



class CenAnnounceDetailController: UIViewController{
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var authorLabel: UILabel!
  @IBOutlet weak var titleHeightLayout: NSLayoutConstraint!

  
  var wkWebView:WKWebView?
  var model:AnnoModel?
  
  let screenSize = UIScreen.main.bounds.size
  
  //MARK:- Overrides
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder);
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad();
    self.title = "公告详情"
    let mainSize = UIScreen.main.bounds.size;
    self.wkWebView = WKWebView.init(frame: CGRect(x: 0, y: 90, width: mainSize.width, height: mainSize.height))
    if let kWebView = self.wkWebView{
      self.view.addSubview(kWebView)
      kWebView.backgroundColor = UIColor.green
      
    }
//    let limitWidth = screenSize.width - (16 * 2)
//    let titleFont = self.titleLabel.font!
//    if let titleHeight = self.titleLabel.text?.strHeightWith(font: titleFont, limitWidth: limitWidth){
//      self.titleHeightLayout.constant = titleHeight
//    }
    self.updateUI()
  }
  
  //MARK:- setter
  
  //MARK:- update ui
  func updateUI() -> Void {
    self.titleLabel.text = self.model?.title ?? ""
    self.authorLabel.text = self.model?.person ?? ""
    
    if let content = self.model?.content,let kWebView = self.wkWebView{
      let string = content.decode64String()
      kWebView.loadHTMLString(string, baseURL: nil)
    }
  }
  
  
}


