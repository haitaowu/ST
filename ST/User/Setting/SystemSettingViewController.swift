//
//  SystemSettingViewController.swift
//  ST
//
//  Created by yunchou on 2016/10/29.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit

class SystemSettingViewController: UIViewController {
    @IBOutlet weak var gridView: GridView!
    @IBOutlet weak var gridContainer: UIView!
    let xiugaimima:SystemSettingEntryType1 = Bundle.main.loadNibView(name: "SystemSettingEntryType1")
    let qingkongshuju:SystemSettingEntryType1 = Bundle.main.loadNibView(name: "SystemSettingEntryType1")
    let saomiaoYundanhouBuPaizhao:SystemSettingEntryType2 = Bundle.main.loadNibView(name: "SystemSettingEntryType2")
    let dingshishangchuashezhi:SystemSettingEntryType2 = Bundle.main.loadNibView(name: "SystemSettingEntryType2")
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "系统设置"
        
        self.xiugaimima.label.text = "修改密码"
        self.xiugaimima.iconView.image = UIImage(named: "resetpw_item_img")
        self.xiugaimima.key = "xiugaimima"
        self.xiugaimima.onClicked = onCommand
        self.qingkongshuju.label.text = "清空数据"
        self.qingkongshuju.iconView.image = UIImage(named: "cleardata_item_img")
        self.qingkongshuju.key = "qingkongshuju"
        self.qingkongshuju.onClicked = onCommand
        self.saomiaoYundanhouBuPaizhao.label.text = "扫描运单后不拍照"
        self.saomiaoYundanhouBuPaizhao.iconView.image = UIImage(named: "nocap_item_img")
        self.saomiaoYundanhouBuPaizhao.key = "saomiaohoubupazhao"
        self.saomiaoYundanhouBuPaizhao.onClicked = onCommand
        self.dingshishangchuashezhi.label.text = "定时上传设置"
        self.dingshishangchuashezhi.iconView.image = UIImage(named: "bt_item_img")
        self.dingshishangchuashezhi.key = "dingshishangchuan"
        self.dingshishangchuashezhi.onClicked = onCommand
        self.gridContainer.borderColor = UIColor.appLineColor
        self.gridContainer.borderWidth = 0.5
        self.gridContainer.cornerRadius = 6
        self.gridView.numOfColsPerRow = 1
        self.gridView.preferRowHeight = 44
        self.gridView.views = [self.xiugaimima,self.qingkongshuju]
        // Do any additional setup after loading the view.
    }
    func onCommand(key:String){
        if key == "qingkongshuju"{
            self.qingkongShuju()
        }else if key == "xiugaimima"{
            self.xiugaiMima()
        }
    }
    private func xiugaiMima(){
        let vc = XiugaimimaViewController(nibName: "XiugaimimaViewController", bundle: nil)
        vc.delegate = self
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    private func qingkongShuju(){
        let alert = UIAlertController(title: "清空数据", message: "确定要清空所有数据吗？", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "确定", style: UIAlertAction.Style.default, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
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

extension SystemSettingViewController:XiugaimimaViewControllerDelegate{

    func xiugaimimaSuccess() {
        _ = self.navigationController?.popViewController(animated: true)
    }
}
