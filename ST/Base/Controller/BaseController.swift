//
//  BaseController.swift
//  ST
//
//  Created by taotao on 2020/4/4.
//  Copyright © 2020 HTT. All rights reserved.
//

import Foundation
import DZNEmptyDataSet



class BaseController: UIViewController,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate{
	
	//MARK:- DZNEmptyDataSetSource
	func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
		return self.titleForEmpty(forEmptyDataSet: scrollView)
	}
	
	
	func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControl.State) -> NSAttributedString! {
		return self.titleForEmptyBtn(forEmptyDataSet: scrollView)
		
	}

	
	//MARK:- DZNEmptyDataSetDelegate
	func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
		self.reloadViewData(scrollView: scrollView)
	}
	
	
	//MARK:- public methods
	///数据为空时显示的title
	public func titleForEmpty(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString?{
		return nil
	}
	
	///数据为空时显示button的title
	public func titleForEmptyBtn(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString?{
		return nil
	}
	
	///点击空button重新加载数据
	public func reloadViewData(scrollView: UIScrollView!){
	}
	
	
}
