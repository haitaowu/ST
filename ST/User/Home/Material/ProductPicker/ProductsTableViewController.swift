//
//  ProductsTableViewController.swift
//  ST
//
//  Created by taotao on 2017/9/9.
//  Copyright © 2017年 dajiazhongyi. All rights reserved.
//



import Alamofire
import UIKit
import HandyJSON

typealias SelectBlock = (NSDictionary)->()


class ProductsTableViewController: UITableViewController,UISearchBarDelegate{
    var searchBar:UISearchBar!
    var products:NSArray?
    var allProducts:NSArray?
    var selectBlock:SelectBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "品名";
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier");
        
        self.searchBar = UISearchBar(frame:CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
        self.tableView.tableHeaderView = self.searchBar
        self.searchBar.delegate = self
        
        self.requestProducts();
    }
    
    //MARK:- request sever
    func requestProducts() {
        let reqUrl = Consts.Server+Consts.BaseUrl+"/initGoodInfo.do"
        Alamofire.request(reqUrl, method: .post, parameters: nil).responseJSON { response in
            if let json = response.result.value as? NSDictionary{
                //获取字典里面的key为数组
                let items = json.value(forKey: "data")as! NSArray
                self.products = items;
                self.allProducts = items;
                self.tableView.reloadData()
            }
        }
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let array = self.products{
            return array.count;
        }else{
            return 0;
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as UITableViewCell
        if let array = self.products{
            let dict = array[indexPath.row] as? NSDictionary;
            let name = dict?["GOODS_NAME"];
            cell.textLabel?.text = name as? String;
        }
        return cell
    }
    
    //MARK:- Table view delegate 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let array = self.products{
            let dict = array[indexPath.row] as? NSDictionary;
            if let block = self.selectBlock{
                block(dict!);
            }
        }
        self.navigationController?.popViewController(animated: true);
    }
    
    //MARK:- UIScrollViewDelegate
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
        self.products = self.allProducts;
        self.tableView.reloadData()
    }
    
    //MARK:- UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.products = self.allProducts;
        }else{
            let searchArray = self.searchFor(searchName: searchText)
            self.products = searchArray;
        }
        self.tableView.reloadData();
    }
    
    func searchFor(searchName:String) -> NSArray {
        let searchArray = NSMutableArray();
        if let array = self.allProducts {
            for product in array{
                let dict = product as? NSDictionary;
                if let name = dict?["GOODS_NAME"] as? String{
                    if name .contains(searchName) {
                        searchArray.add(product)
                    }
                }
            }
        }
        return searchArray;
    }
    
}
