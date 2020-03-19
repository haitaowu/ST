//
//  WebViewController.swift
//  ST
//
//  Created by yunchou on 2016/11/15.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    @IBOutlet weak var webView: WebView!
    private var url:String = ""
    private var html:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        if !self.url.isEmpty{
            self.webView.loadUrl(url: self.url)
        }else if !self.html.isEmpty{
            self.webView.loadHtml(html: self.html)
        }
        
        // Do any additional setup after loading the view.
    }

    convenience init(url:String){
        self.init(nibName: "WebViewController", bundle: nil)
        self.url = url
    }
    convenience init(html:String){
        self.init(nibName: "WebViewController", bundle: nil)
        self.html = html
    }
    convenience init(bundleName:String){
        self.init(nibName: "WebViewController", bundle: nil)
        self.url = "file://".appending(Bundle.main.bundlePath.appending("/html/\(bundleName).html"))
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
