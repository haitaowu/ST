//
//  HomeViewController.swift
//  ST
//
//  Created by yunchou on 2016/10/26.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit



class HomeViewController: UIViewController {
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var bottomContainer: UIScrollView!
    @IBOutlet weak var gridView: GridView!
    @IBOutlet weak var gridHeaderView: UIView!
    @IBOutlet weak var gridFooterView: UIView!
    private var menuItems:[HomeMenuItems] = []
    //MARK:- override methods
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
        self.title = DataManager.shared.loginUser.siteName
        self.topContainer.borderColor = UIColor.appLineColor
        self.topContainer.topBorderWidth = 0.5
        self.topContainer.bottomBorderWidth = 0.5
        self.menuItems = [
            (title:"单件录入",icon:"home_menu_1",key:"danjian",handler:menuItemviewClicked),
            (title:"运单补打",icon:"home_menu_10",key:"latebill",handler:menuItemviewClicked),
            (title:"收件扫描",icon:"home_menu_2",key:"shoujian",handler:menuItemviewClicked),
            (title:"发件扫描",icon:"home_menu_3",key:"fajian",handler:menuItemviewClicked),
            (title:"到件扫描",icon:"home_menu_4",key:"daojian",handler:menuItemviewClicked),
            (title:"派件扫描",icon:"home_menu_5",key:"paijian",handler:menuItemviewClicked),
            (title:"签收操作",icon:"home_menu_6",key:"qianshou",handler:menuItemviewClicked),
            (title:"问题件操作",icon:"home_menu_7",key:"wentijian",handler:menuItemviewClicked),
            (title:"快件查询",icon:"home_menu_8",key:"kuaichaxun",handler:menuItemviewClicked),
            (title:"区域查询",icon:"home_menu_9",key:"quyuchaxun",handler:menuItemviewClicked),
//            (title:"物料申请",icon:"material",key:"wuliaoshenqin",handler:menuItemviewClicked),
            //            (title:"结算充值",icon:"",key:"jiesuanchongzhi",handler:menuItemviewClicked),
//            (title:"",icon:"",key:"empty",handler:menuItemviewClicked)
        ]
        self.gridView.numOfColsPerRow = 3
        self.gridView.preferRowHeight = UIScreen.main.bounds.width / 3 - 10
        
        self.gridFooterView.borderColor = UIColor.appLineColor
        self.gridFooterView.topBorderWidth = 0.5
        self.gridHeaderView.borderColor = UIColor.appLineColor
        self.gridHeaderView.topBorderWidth = 0.5
        
        let siteName = DataManager.shared.loginUser.siteName
        if siteName == "总部"{
            self.menuItems.append((title:"财务充值",icon:"financial",key:"financial",handler:menuItemviewClicked))
        }
        self.gridView.setupWith(items: self.menuItems)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- setup ui
    private func setupTabbarItem(){
        self.tabBarItem = UITabBarItem(title: "首页", image:UIImage(named:"home_disselect") , selectedImage: UIImage(named:"home_select"))
    }
    
    func menuItemviewClicked(type:String){
        NSLog("menu item clicked:\(type)")
        if type == "shoujian"{
            self.openShoujianSaomiao()
        }else if type == "fajian"{
            self.openFajianSaomiao()
        }else if type == "daojian"{
            self.openDaojianSaomiao()
        }else if type == "paijian"{
            self.openPaijianSaomiao()
        }else if type == "qianshou"{
            self.openQianshou()
        }else if type == "wentijian"{
            self.openWentijian()
        }else if type == "kuaichaxun"{
            self.openKuaijianchaxun()
        }else if type == "quyuchaxun"{
            self.openQuyuchaxun()
        }else if type == "wuliaoshenqin"{
            self.openMaterialView();
        }else if type == "financial"{
            self.openFinancialView();
        }else if type == "danjian"{
            self.openBillPrintView();
        }else if type == "latebill"{
            self.openLateBillPrintView();
        }
    }
    //打印运单界面
    func openBillPrintView(){
//        let vc = FinancialController(nibName: "FinancialController", bundle: nil)
//        vc.hidesBottomBarWhenPushed = true
        let storyboard = UIStoryboard.init(name: "BaseUI", bundle: nil);
        let printerVc = storyboard.instantiateViewController(withIdentifier: "BillRecordTableController");
        printerVc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(printerVc, animated: true)
    }
    
    //补打印运单界面
    func openLateBillPrintView(){
        let storyboard = UIStoryboard.init(name: "BaseUI", bundle: nil);
        let printerVc = storyboard.instantiateViewController(withIdentifier: "LaterPinterBillTableController");
        printerVc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(printerVc, animated: true)
    }
    
    func openFinancialView(){
        let vc = FinancialController(nibName: "FinancialController", bundle: nil)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openQuyuchaxun(){
        let vc = QuyuChaxunViewController(nibName: "QuyuChaxunViewController", bundle: nil)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openKuaijianchaxun(){
        let vc = KuaijianChaxunViewController(nibName: "KuaijianChaxunViewController", bundle: nil)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openWentijian(){
        let vc = WentijianCaozuoViewController(nibName: "WentijianCaozuoViewController", bundle: nil)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func openQianshou(){
        let vc = QianshouCaozuoViewController(nibName: "QianshouCaozuoViewController", bundle: nil)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openPaijianSaomiao(){
        let vc = PaijianSaomiaoViewController(nibName: "PaijianSaomiaoViewController", bundle: nil)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openFajianSaomiao(){
        let vc = FajianSaomiaoViewController(nibName: "FajianSaomiaoViewController", bundle: nil)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openShoujianSaomiao(){
        let vc = ShoujianSaomiaoViewController(nibName: "ShoujianSaomiaoViewController", bundle: nil)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openDaojianSaomiao(){
        let vc = DaojianSaomiaoViewController(nibName: "DaojianSaomiaoViewController", bundle: nil)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
   //打开物料申请界面
    func openMaterialView(){
        let vc = MaterialViewController(nibName: "MaterialViewController", bundle: nil)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
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
