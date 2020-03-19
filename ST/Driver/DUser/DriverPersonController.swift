//
//  DriverPersonController.swift
//  ST
//
//  Created by taotao on 2019/5/27.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import UIKit



class DriverPersonController: UITableViewController {
    
    //MARK:- Overrides
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
        self.setupTabBarItems();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.setupTabBarItems();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = "用户";
    }
    
    //MARK:- public 
    static func DriverUserControl() -> UIViewController{
        let storyboard = UIStoryboard.init(name: "Driver", bundle: nil)
        let control = storyboard.instantiateViewController(withIdentifier: "DriverPersonController")
        return control;
    }
    
    //MARK:- setup tabbaritem
    func setupTabBarItems() -> Void {
        self.tabBarItem = UITabBarItem(title: "用户", image:UIImage(named:"individual_disselect") , selectedImage: UIImage(named:"individual_select"));
    }
    
    
    //MARK:- selectors
    //基础资料修改
    @IBAction func clickBseInfoBtn(_ sender: Any) {
        print("基础资料修改")
    }
    
    //堵车报备查询
    @IBAction func clickHeavyBtn(_ sender: Any) {
        let control = DriHeavQueryController.HeavQueryControl()
        self.navigationController?.pushViewController(control, animated: true)
        print("堵车报备查询")
    }
    
    //车损报备查询
    @IBAction func clickCarDamBtn(_ sender: Any) {
        print("车损报备查询")
        let control = DriDamgeQueryController.DamgeQueryControl()
        self.navigationController?.pushViewController(control, animated: true)
    }
    

    //退出登录
    @IBAction func clickLogoutBtn(_ sender: Any) {
        self.logout()
    }
    
    //MARK:- tableview delegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    
    //MARK:- private
    //退出登录
    func logout(){
        let alert = UIAlertController(title: "退出登陆", message: "确定要退出登陆？", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "确定", style: UIAlertAction.Style.default, handler: { (action) in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "logout"), object: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}


