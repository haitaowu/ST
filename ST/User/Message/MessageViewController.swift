//
//  MessageViewController.swift
//  ST
//
//  Created by yunchou on 2016/10/26.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit
import Alamofire



class MessageViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    @IBOutlet weak var tableView: UITableView!
    
    let cellReuserID = "noticeCellID"
    var noticesData:NSArray?
    
    //MARK:-  override methods
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.setupTabbarItem()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupTabbarItem()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = false
        self.title = "公告"
        let nib = UINib.init(nibName: "NoticeCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: cellReuserID)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reqMessages()
    }
    
    
    //MARK:- private 
    private func setupTabbarItem(){
        self.tabBarItem = UITabBarItem(title: "消息", image:UIImage(named:"notification_disselected") , selectedImage: UIImage(named:"notification_selected"))
    }
    
    // MARK: - Table view data source
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let array = self.noticesData{
            return array.count;
        }else{
            return 10;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuserID, for: indexPath) as! NoticeCell
        if let array = self.noticesData{
            let notiData = array[indexPath.row]
            cell.noticeData = notiData as? NSDictionary
        }
        return cell
    }
    
    //MARK:- Table view delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = NoticeDetailController(nibName: "NoticeDetailController", bundle: nil)
        if let array = self.noticesData{
            let notiData = array[indexPath.row]
            vc.noticeData = notiData as? NSDictionary
        }
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }

    //MARK:- request server
    func reqMessages() {
        let reqUrl = Consts.Server+Consts.BaseUrl+"/searchSiteNotice.do"
//        let parameters: Parameters = ["foo": "bar"]
        Alamofire.request(reqUrl, method: .post, parameters: nil).responseJSON { response in
//            print("Request: \(String(describing: response.request))")   // original url request
//            print("Response: \(String(describing: response.response))") // http url response
//            print("Result: \(response.result)")                         // response serialization result
            
            if let json = response.result.value {
                print("result.value: \(json)") // serialized json response
            }
            
            if let json = response.result.value as? NSDictionary{
                if let data = json.value(forKey: "data"){
                    self.noticesData = data as? NSArray
                    self.tableView.reloadData()
                }
            }
        }
    }

}
