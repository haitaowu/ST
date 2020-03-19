//
//  NoticeDetailController.swift
//  ST
//
//  Created by taotao on 2017/9/11.
//  Copyright © 2017年 dajiazhongyi. All rights reserved.
//

import UIKit
import QuickLook
import Alamofire


class NoticeDetailController: UIViewController ,QLPreviewControllerDataSource{
    @IBOutlet weak var attachNameLabel: UILabel!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTxtView: UITextView!
    
    var noticeData:NSDictionary?

    //MARK:- override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "公告详情"
        self.attachNameLabel.layer.borderColor = UIColor.black.cgColor
        self.attachNameLabel.layer.borderWidth = 1
        
        self.downloadBtn.layer.borderColor = UIColor.black.cgColor
        self.downloadBtn.layer.borderWidth = 1
        
        self.titleLabel.layer.borderColor = UIColor.black.cgColor
        self.titleLabel.layer.borderWidth = 1
        
        if let data = self.noticeData{
            let CONTENT = data.value(forKey: "CONTENT") as? String;
            if (CONTENT?.isEmpty)!{
                self.contentTxtView.text = CONTENT
            }else{
                self.contentTxtView.text = ""
            }
            let TITLE = data.value(forKey: "TITLE") as? String;
            if TITLE != nil{
                self.titleLabel.text = TITLE;
            }else{
                self.titleLabel.text = "";
            }
        }
        
        if self.hasAttachFile(){
            self.downloadBtn.isEnabled = false
            if self.fileExistsWith(){
                self.downloadBtn.setTitle("已下载", for: .normal)
            }else{
                self.downloadBtn.setTitle("下载", for: .normal)
            }
        }else{
            self.downloadBtn.isEnabled = true
        }
    }

    //MARK:- selectors
    @IBAction func tapAttacthBtn(_ sender: UIButton) {
        if sender.isSelected == true{
            let quickControl = QLPreviewController.init();
            quickControl.dataSource = self;
            self.navigationController?.pushViewController(quickControl, animated: true)
        }else{
            let downloadPath = self.downloadPath()
            self.downloadAttachWith(path:downloadPath)
        }
    }
    
    //MARK:- private methods
    func fileLocalPath() -> String {
        let attachName = self.attachFileName()
        let filePath:String = NSHomeDirectory() + "/Documents/" + attachName
        return filePath
    }
    
    //check if does it have attachment
    func hasAttachFile() -> Bool{
        let attachName = self.attachFileName()
        if attachName.isEmpty{
            return false
        }else{
            return true
        }
    }
    
    //检查文件是否存在
    func fileExistsWith() -> Bool{
        let attachName = self.attachFileName()
        if attachName.isEmpty{
            return false
        }else{
            let fileManager = FileManager.default
            let filePath:String = self.fileLocalPath()
            let exist = fileManager.fileExists(atPath: filePath)
            return exist;
        }
    }
    
    //attach file name
    func attachFileName() -> String{
        if let dict = self.noticeData{
            if let attachName = dict.value(forKey: "FILE_NAME"){
                return attachName as! String
            }else{
                return ""
            }
        }else{
            return ""
        }
    }
    
    //down load path
    func downloadPath() -> String{
        if let dict = self.noticeData{
            if let downloadPath = dict.value(forKey: "FILE_PATH"){
                return downloadPath as! String
            }else{
                return ""
            }
        }else{
            return ""
        }
    }
    
    func docUrl() -> NSURL{
        if let path = Bundle.main.path(forResource: "testDoc", ofType: "xlsx"){
            let url = NSURL.init(fileURLWithPath: path);
            return url;
        }else{
            return NSURL();
        }
    }
    
    //文档存储到本地
    func saveDocToLocal(docData:Data){
        let filePath:String = self.fileLocalPath()
        let url = URL.init(fileURLWithPath: filePath)
        do{
            try docData.write(to: url)
            self.downloadBtn.setTitle("已下载", for: .normal)
        }catch{
            NSLog("write fiel to local documents failed")
        }
    }
    
    //MARK:- QLPreviewControllerDataSource
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let url = self.docUrl();
        return url;
    }

    //MARK:-  request server 
    func downloadAttachWith( path:String){
        Alamofire.download(path)
            .downloadProgress { progress in
                print("Download Progress: \(progress.fractionCompleted)")
            }
            .responseData { response in
                if let data = response.result.value {
                    self.saveDocToLocal(docData: data)
//                    let image = UIImage(data: data)
                }
        }
    }
}
