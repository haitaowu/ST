//
//  STListView.swift
//  ST
//
//  Created by yunchou on 2016/11/7.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit

protocol STListViewDelegate:NSObjectProtocol{
    var headers:[String]{get}
    var objects:[STListViewModel]{get}
    var columnPercents:[CGFloat]{get}
    func onObjectSelect(object:STListViewModel)
    func deleteObject(object:STListViewModel) -> Bool
}

extension STListViewDelegate{
    func onObjectSelect(object:STListViewModel){}
    func deleteObject(object:STListViewModel) -> Bool{ return false }
}
class STListLineView: UIView {
    var titleColor = UIColor.white
    var titleFont = UIFont.systemFont(ofSize: 14)
    var bgColor = UIColor.darkGray
    var columnPercents:[CGFloat] = []
    var columnNames:[String] = []{
        didSet{ setupViews() }
    }
    private func makeLabel(string:String) -> UILabel{
        let label = UILabel()
        label.text = string
        label.textAlignment = .center
        label.backgroundColor = bgColor
        label.textColor = titleColor
        label.font = titleFont
        return label
    }
    private func setupViews(){
        self.subviews.forEach{ $0.removeFromSuperview() }
        self.columnNames.map(makeLabel).forEach{ addSubview($0) }
        self.clipsToBounds = true
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = self.frame.width
        let h = self.frame.height
        var offset:CGFloat = 0
        for i in 0 ..< min(self.columnPercents.count, self.columnNames.count){
            let v = self.subviews[i]
            let p = self.columnPercents[i]
            let width = w * p
            v.frame = CGRect(x: offset, y: 0, width: width, height: h)
            offset += width
        }
    }
}
class STListView:UIView{
    weak var delegate:STListViewDelegate?
    var tableView:UITableView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    private func commonInit(){
        self.tableView = UITableView()
        self.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = UIColor.lightGray
        self.tableView.estimatedRowHeight = 22
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.tableFooterView = UIView()
        let cellNib = UINib(nibName: "STListViewCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: "STListViewCell")
    }
    func reloadData(){
        self.tableView.separatorStyle = .none
        self.tableView.reloadData()
    }
}

extension STListView:UITableViewDataSource,UITableViewDelegate{
    private func cellWithModel(model:STListViewModel) -> UITableViewCell{
        let cell:STListViewCell = self.tableView.dequeueReusableCell(withIdentifier: "STListViewCell") as! STListViewCell
        cell.lineView.columnPercents = delegate!.columnPercents
        cell.lineView.columnNames = model.columnNames
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = STListLineView()
        v.titleColor = UIColor.black
        v.bgColor = UIColor.lightGray
        v.titleFont = UIFont.boldSystemFont(ofSize: 16)
        v.columnNames = delegate!.headers
        v.columnPercents = delegate!.columnPercents
        
        return v
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let delegate = self.delegate{
            return delegate.objects.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let delegate = self.delegate{
            let model = delegate.objects[indexPath.row]
            return self.cellWithModel(model: model)
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let dlg = self.delegate else{ return }
        dlg.onObjectSelect(object: dlg.objects[indexPath.row])
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let dlg = self.delegate else{ return }
        if editingStyle == .delete{
            if dlg.deleteObject(object: dlg.objects[indexPath.row]){
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            }
        }
    }
}
extension STListView{
    func styleme(){
        self.borderColor = UIColor.appLineColor
        self.bottomBorderWidth = 0.5
        self.topBorderWidth = 0.5
    }
}
