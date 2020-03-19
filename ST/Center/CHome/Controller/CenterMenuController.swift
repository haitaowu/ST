//
//  CenterMenuController.swift
//  ST
//
//  Created by taotao on 2019/5/27.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import UIKit



class CenterMenuController: UIViewController,UITableViewDataSource,UITableViewDelegate{
   
    var menuAry:Array<Any>?
    
    //MARK:-IBoutlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Overrides
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.setupTableView()
        self.setupController()
        initMenuCell();
    }
    
    //MARK:- setup
    func setupController() -> Void {
        self.title = "中心菜单";
    }
    
    func setupTableView() -> Void {
        let menuCell = STMenuCell.cellNib();
        self.tableView.register(menuCell, forCellReuseIdentifier: STMenuCell.cellID())
    }
    
    func initMenuCell(){
        self.menuAry = Array()
        let navStr = CellMenuType.arrive.rawValue + ",到车登记"
        self.menuAry?.append(navStr)
        let alertStr = CellMenuType.send.rawValue + ",发车登记"
        self.menuAry?.append(alertStr)
    }
    
    //MARK:- private methods
    func showMenu(menuStr: String) -> Void {
        if menuStr == CellMenuType.arrive.rawValue {
            let storyboard = UIStoryboard.init(name: "STCenter", bundle: nil)
            let control = storyboard.instantiateViewController(withIdentifier: "CenArriSignController")
            self.navigationController?.pushViewController(control, animated: true)
        }else if menuStr == CellMenuType.send.rawValue {
            let storyboard = UIStoryboard.init(name: "STCenter", bundle: nil)
            let control = storyboard.instantiateViewController(withIdentifier: "CenSendSignController")
            self.navigationController?.pushViewController(control, animated: true)
        }else{
        }
    }
    
   

    
    //MARK:- tableView datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let ary = self.menuAry{
            return ary.count
        }else{
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: STMenuCell.cellID()) as! STMenuCell
        if let ary = self.menuAry{
            let cellData = ary[indexPath.row] as! String
//            cell.setupCell(dataStr: cellData)
        }
        return cell;
    }
    
    
    //MARK:- tableView delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let ary = self.menuAry{
            let cellData = ary[indexPath.row] as! String
            if let type = cellData.components(separatedBy: ",").first{
                print("type = "+type)
                self.showMenu(menuStr: type)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40;
    }
    
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    
}


