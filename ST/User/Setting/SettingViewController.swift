//
//  SettingViewController.swift
//  ST
//
//  Created by yunchou on 2016/10/26.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
    private var settings:[SettingEntryItem] = []
    @IBOutlet weak var gridContainer: UIView!
    @IBOutlet weak var gridView: GridView!
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.setupTabbarItem()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupTabbarItem()
    }
    
    private func setupTabbarItem(){
        self.tabBarItem = UITabBarItem(title: "设置", image:UIImage(named:"more_disselect") , selectedImage: UIImage(named:"more_select"))
    }
    func entryViewClicked(key:String){
        NSLog("click entry \(key)")
        if key == "xitongshezhi"{
            self.openXitongShezhi()
        }else if key == "shiyongbangzhu"{
            self.openHelpView()
        }else if key == "guanyuwomen"{
            self.openAboutView()
        }else if key == "tuichudenglu"{
            self.logout()
        }
    }
    
    func logout(){
        let alert = UIAlertController(title: "退出登陆", message: "确定要退出登陆？", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "确定", style: UIAlertAction.Style.default, handler: { (action) in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "logout"), object: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func openHelpView(){
        let vc = WebViewController(bundleName: "help")
        vc.hidesBottomBarWhenPushed = true
        vc.title = "使用帮助"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func openAboutView(){
        let vc = WebViewController(bundleName: "about")
        vc.hidesBottomBarWhenPushed = true
        vc.title = "关于我们"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func openXitongShezhi(){
        let vc = SystemSettingViewController(nibName: "SystemSettingViewController", bundle: nil)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = false
        self.title = "设置"
        self.view.backgroundColor = UIColor.appBgColor
        self.gridContainer.borderColor = UIColor.appLineColor
        self.gridContainer.borderWidth = 0.5
        self.gridContainer.cornerRadius = 6
        self.gridView.numOfColsPerRow = 1
        self.gridView.preferRowHeight = 44
        self.settings = [
            (icon:"setting_item_img",title:"系统设置",key:"xitongshezhi",handler:entryViewClicked),
//            (icon:"update_item_img",title:"检查更新",key:"jianchagengx",handler:entryViewClicked),
//            (icon:"help_item_img",title:"使用帮助",key:"shiyongbangzhu",handler:entryViewClicked),
            (icon:"logout_item_img",title:"退出登录",key:"tuichudenglu",handler:entryViewClicked),
            (icon:"aboutus_item_img",title:"关于我们",key:"guanyuwomen",handler:entryViewClicked),
        ]
        self.gridView.setupWith(items: self.settings)
        // Do any additional setup after loading the view.
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
