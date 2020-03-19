//
//  GridView.swift
//  GridView
//
//  Created by aixinyunchou@icloud.com on 16/9/1.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit

class GridView: UIView {
    var preferRowHeight:CGFloat = 50 //每行高度
    var lineColor:UIColor = UIColor.appLineColor
    var numOfColsPerRow:Int = 2  //列数
    var numOfRows:Int = 0
    private var contentView:UIView!
    var views:[UIView] = [] {
        didSet{ setupViews(oldViews: oldValue) }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override func becomeFirstResponder() -> Bool {
        return self.views.last?.becomeFirstResponder() ?? false
    }
    private func commonInit(){
        self.contentView = UIView()
        self.addSubview(self.contentView)
    }
    private func setupViews(oldViews:[UIView]){
        oldViews.forEach{ $0.removeFromSuperview() }
        self.views.forEach{
            self.addSubview($0)
        }
        self.updateView()
    }
    private func updateView(){
        self.numOfRows = Int(ceil(Double(self.views.count) / Double(numOfColsPerRow)))
        self.updateGridStyle()
        self.setNeedsLayout()
        self.layoutSubviews()
    }
    private func makeFrame(row:Int,col:Int) -> CGRect{
        let w = self.frame.width / CGFloat(numOfColsPerRow)
        return CGRect(x: w * CGFloat(col), y: preferRowHeight * CGFloat(row), width: w, height: preferRowHeight)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let rows = CGFloat(self.numOfRows)
        self.contentView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: rows * preferRowHeight)
        let viewCount = self.views.count
        for i in 0 ..< viewCount {
            let v = self.views[i]
            let row = i / numOfColsPerRow
            let col = i % numOfColsPerRow
            v.frame = self.makeFrame(row: row, col: col)
        }
        self.invalidateIntrinsicContentSize()
    }
    override var intrinsicContentSize: CGSize{
        let rows = CGFloat(self.numOfRows)
        return CGSize(width: self.frame.width, height: rows * preferRowHeight)
    }
    
    private func setStyle(v:UIView,row:Int,col:Int){
        let rows = Int(ceil(Double(self.views.count) / Double(numOfColsPerRow)))
        if col != self.numOfColsPerRow - 1 {
            v.borderColor = lineColor
            v.rightBorderWidth = 0.5
        }else{
            v.borderColor = UIColor.clear
            v.rightBorderWidth = 0
        }
        if row != rows - 1 {
            v.borderColor = lineColor
            v.bottomBorderWidth = 0.5
        }else{
            v.borderColor = UIColor.clear
            v.bottomBorderWidth = 0
        }
    }
    private func updateGridStyle(){
        let viewCount = self.views.count
        for i in 0 ..< viewCount {
            let v = self.views[i]
            let row = i / numOfColsPerRow
            let col = i % numOfColsPerRow
            self.setStyle(v: v, row: row, col: col)
        }
    }
}
