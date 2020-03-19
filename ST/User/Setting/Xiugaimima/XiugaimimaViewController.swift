//
//  XiugaimimaViewController.swift
//  ST
//
//  Created by yunchou on 2016/11/15.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit

protocol XiugaimimaViewControllerDelegate:NSObjectProtocol{
    func xiugaimimaSuccess()
}

class XiugaimimaViewController: UIViewController {
    weak var delegate:XiugaimimaViewControllerDelegate?
    @IBOutlet weak var oldPasswordField: UITextField!

    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var newPasswordField2: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var confirmChange: StBottomButton!
    @IBAction func confirmChangeBtnClicked(_ sender: Any) {
        let pass = self.oldPasswordField.text ?? ""
        let newpass = self.newPasswordField.text ?? ""
        let newpass2 = self.newPasswordField2.text ?? ""
        if pass.isEmpty{
            self.remindUser(msg: "原密码不能为空")
            return
        }
        if newpass.isEmpty{
            self.remindUser(msg: "新密码不能为空")
            return
        }
        if newpass != newpass2{
            self.remindUser(msg: "两次输入新密码不一致")
            return
        }
        if pass != DataManager.shared.loginUser.barPassword{
            self.remindUser(msg: "原登陆密码错误")
            return
        }
        delegate?.xiugaimimaSuccess()
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
