//
//  DbObject.swift
//  ST
//
//  Created by yunchou on 2016/11/7.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import Foundation

struct DbObject<T:SimpleCodable>:SimpleCodable {
    var value:T = T()
}
