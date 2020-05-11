//
//  ProblemItemReason.swift
//  ST
//
//  Created by yunchou on 2016/11/5.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import Foundation

struct ProblemItemReason:SimpleCodable {
    var problemCode:String = ""
    var problem:String = ""
    var modifyDate:String = ""
    var deleteFlag:Int = 0
}

struct ProblemItemReasonLoadRequest:STRequest {
    var logicUrl: String{
        return "/initPType.do"
    }
}

struct ProblemItemReasonsViewModel {
    var problems:[ProblemItemReason] = []
    
}

extension ProblemItemReasonsViewModel:PickerInputViewModel{
    func componentsCount() -> Int{
        return 1
    }
    func rowCountForComponent(c:Int) -> Int{
        return problems.count
    }
    func titleForRow(row:Int,component:Int) -> String{
        return problems[row].problem
    }
}
