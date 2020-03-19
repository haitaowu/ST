//
//  CenAnnounceDetailController.swift
//  ST
//
//  Created by taotao on 2019/5/27.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import UIKit



class CenAnnounceDetailController: UIViewController{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var contentTxtView: UITextView!
    @IBOutlet weak var titleHeightLayout: NSLayoutConstraint!
    
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
        let limitWidth = screenSize.width - (16 * 2)
        let titleFont = self.titleLabel.font!
        if let titleHeight = self.titleLabel.text?.strHeightWith(font: titleFont, limitWidth: limitWidth){
            self.titleHeightLayout.constant = titleHeight
        }
        self.updateUI()
    }

    //MARK:- setter

    //MARK:- update ui
    func updateUI() -> Void {
        self.titleLabel.text = self.model?.title ?? ""
        self.authorLabel.text = self.model?.person ?? ""
        self.contentTxtView.text = self.model?.content ?? ""
    }
    

}


