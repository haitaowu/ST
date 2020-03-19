//
//  STDb.swift
//  IOS10Learn
//
//  Created by yunchou on 2016/11/8.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import Foundation
import GRDB
class STDb{
    static var shared = STDb()
    private var dbPool:DatabasePool!
    private func traceFunction(msg:String){
        print("db -> \(msg)")
    }
    private init(){
        var dbConfig = Configuration()
        dbConfig.trace = traceFunction
        let dbPath = NSHomeDirectory().appending("/Documents/data.db")
        self.dbPool = try! DatabasePool(path: dbPath, configuration: dbConfig)
        self.createSjTable()
        self.createFjTable()
        self.createDjTable()
        self.createPjTable()
        self.createQsTable()
        self.createWtjTable()
    }
    private func createSjTable(){
        do{
            try self.dbPool.write { (db) -> Void in
                try? db.create(table: "sj", temporary: false, ifNotExists: true, body: { (t) in
                    t.column("ydh", Database.ColumnType.text).primaryKey().unique(onConflict: Database.ConflictResolution.replace)
                    t.column("sjy", Database.ColumnType.text)
                    t.column("ts", Database.ColumnType.text)
                })
            }
        } catch let error as DatabaseError{
            print("CreateEror:"+error.description)
        }catch{
            
        }
    }
    private func createFjTable(){
        do{
            try self.dbPool.write { (db) -> Void in
                try? db.create(table: "fj", temporary: false, ifNotExists: true, body: { (t) in
                    t.column("ydh", Database.ColumnType.text).primaryKey().unique(onConflict: Database.ConflictResolution.replace)
                    t.column("zd", Database.ColumnType.text)
                    t.column("ysfs", Database.ColumnType.text)
                    t.column("ts", Database.ColumnType.text)
                })
            }
        }catch let error as DatabaseError{
            print("Create fj Eror:"+error.description)
        }catch{
            print("Create fj Eror")
        }
    }
    
    private func createDjTable(){
        do{
            try self.dbPool.write { (db) -> Void in
                try? db.create(table: "dj", temporary: false, ifNotExists: true, body: { (t) in
                    t.column("ydh", Database.ColumnType.text).primaryKey().unique(onConflict: Database.ConflictResolution.replace)
                    t.column("zd", Database.ColumnType.text)
                    t.column("ts", Database.ColumnType.text)
                })
            }
        }catch let error as DatabaseError{
            print("CreateEror:"+error.description)
        }catch{
            
        }
    }
    private func createPjTable(){
        do{
            try self.dbPool.write { (db) -> Void in
                try? db.create(table: "pj", temporary: false, ifNotExists: true, body: { (t) in
                    t.column("ydh", Database.ColumnType.text).primaryKey().unique(onConflict: Database.ConflictResolution.replace)
                    t.column("pjy", Database.ColumnType.text)
                    t.column("ts", Database.ColumnType.text)
                })
            }
        } catch let error as DatabaseError{
            print("CreateEror:"+error.description)
        }catch{
            
        }
    }
    private func createQsTable(){
        do{
            try self.dbPool.write { (db) -> Void in
                try? db.create(table: "qs", temporary: false, ifNotExists: true, body: { (t) in
                    t.column("ydh", Database.ColumnType.text).primaryKey().unique(onConflict: Database.ConflictResolution.replace)
                    t.column("qsr", Database.ColumnType.text)
                    t.column("tp", Database.ColumnType.text)
                    t.column("bz", Database.ColumnType.text)
                    t.column("ts", Database.ColumnType.text)
                })
            }
        } catch let error as DatabaseError{
            print("CreateEror:"+error.description)
        }catch{
            
        }
    }

    private func createWtjTable(){
        do{
            try self.dbPool.write { (db) -> Void in
                try? db.create(table: "wtj", temporary: false, ifNotExists: true, body: { (t) in
                    t.column("ydh", Database.ColumnType.text).primaryKey().unique(onConflict: Database.ConflictResolution.replace)
                    t.column("wtlx", Database.ColumnType.text)
                    t.column("tzzd", Database.ColumnType.text)
                    t.column("wtyy", Database.ColumnType.text)
                })
            }
        } catch let error as DatabaseError{
            print("CreateEror:"+error.description)
        }catch{
            
        }
    }
    func saveSj(model:ShoujianModel){
        do{
            try self.dbPool.write { (db) -> Void in
                try? db.execute(sql: "insert into sj(ydh,sjy,ts) values(:ydh,:sjy,:ts)", arguments: [
                    "ydh":model.billCode,
                    "sjy":model.recMan,
                    "ts":model.scanDate
                    ])
            }
        } catch let error as DatabaseError{
            print("CreateEror:"+error.description)
        }catch{
            
        }
        
    }
    
    func deleteSj(model:ShoujianModel){
        do{
            try self.dbPool.write { (db) -> Void in
                try? db.execute(sql: "delete from sj where ydh=:ydh", arguments: ["ydh":model.billCode])
            }
        } catch let error as DatabaseError{
            print("CreateEror:"+error.description)
        }catch{
            
        }
    }
    
    func allSj() -> [ShoujianModel]{
        do{
            return try self.dbPool.read { (db) -> [ShoujianModel] in
                return try Row.fetchAll(db, sql: "select * from sj").map(ShoujianModel.init)
                }.reversed()
            
        }catch{
            return[];
        }
    }
    
    func removeAllSj(){
        do{
            try self.dbPool.write { (db) -> Void in
                try? db.execute(sql: "delete from sj")
            }
        }catch let error as DatabaseError{
            print("CreateEror:"+error.description)
        }catch{
            
        }
    }
    
    func saveFj(model:FajianModel){
        do{
            try self.dbPool.write { (db) -> Void in
                try? db.execute(sql: "insert into fj(ydh,zd,ysfs,ts) values(:ydh,:zd,:ysfs,:ts)", arguments: [
                    "ydh":model.billCode,
                    "zd":model.preOrNext,
                    "ysfs":"",
                    "ts":model.scanDate
                    ])
            }
        }catch let error as DatabaseError{
            print("write error:"+error.description)
        }catch{
            
        }
    }
    
    func deleteFj(model:FajianModel){
        do{
            try self.dbPool.write { (db) -> Void in
                try? db.execute(sql: "delete from fj where ydh=:ydh", arguments: ["ydh":model.billCode])
            }
        }catch let error as DatabaseError{
            print("write error:"+error.description)
        }catch{
            
        }
    }
    
    func allFj() -> [FajianModel]{
        do{
            return try self.dbPool.read { (db) -> [FajianModel] in
                return try Row.fetchAll(db, sql: "select * from fj").map(FajianModel.init)
                }.reversed()
            
        }catch {
            return[];
        }
    }
    func removeAllFj(){
        do{
            try self.dbPool.write { (db) -> Void in
                try? db.execute(sql: "delete from fj")
            }
        }catch let error as DatabaseError{
            print("write error:"+error.description)
        }catch{
            
        }
    }
    
    func saveDj(model:DaojianModel){
        do{
            try self.dbPool.write { (db) -> Void in
                try? db.execute(sql: "insert into dj(ydh,zd,ts) values(:ydh,:zd,:ts)", arguments: [
                    "ydh":model.billCode,
                    "zd":model.preOrNext,
                    "ts":model.scanDate
                    ])
            }
        }catch let error as DatabaseError{
            print("write error:"+error.description)
        }catch{
            
        }
    }
    
    func deleteDj(model:DaojianModel){
        do{
            try self.dbPool.write { (db) -> Void in
                try? db.execute(sql: "delete from dj where ydh=:ydh", arguments: ["ydh":model.billCode])
            }
        }catch let error as DatabaseError{
            print("write error:"+error.description)
        }catch{
            
        }
    }
    
    func allDj() -> [DaojianModel]{
        do{
            return try self.dbPool.read { (db) -> [DaojianModel] in
                return try Row.fetchAll(db, sql: "select * from dj").map(DaojianModel.init)
                }.reversed()
        }catch{
            return[];
        }
    }
    
    func removeAllDj(){
        do{
            try self.dbPool.write { (db) -> Void in
                try? db.execute(sql: "delete from dj")
            }
        }catch let error as DatabaseError{
            print("write error:"+error.description)
        }catch{
            
        }
    }
    
    func savePj(model:PaijianModel){
        do{
            try self.dbPool.write { (db) -> Void in
                try? db.execute(sql: "insert into pj(ydh,pjy,ts) values(:ydh,:pjy,:ts)", arguments: [
                    "ydh":model.billCode,
                    "pjy":model.dispMan,
                    "ts":model.scanDate
                    ])
            }
        }catch let error as DatabaseError{
            print("write error:"+error.description)
        }catch{
            
        }
    }
    
    func deletePj(model:PaijianModel){
        do{
            try self.dbPool.write { (db) -> Void in
                try? db.execute(sql: "delete from pj where ydh=:ydh", arguments: ["ydh":model.billCode])
            }
        }catch let error as DatabaseError{
            print("write error:"+error.description)
        }catch{
            
        }
    }
    
    func allPj() -> [PaijianModel]{
        do{
            return try self.dbPool.read { (db) -> [PaijianModel] in
                return try Row.fetchAll(db, sql: "select * from pj").map(PaijianModel.init)
            }.reversed()
        }catch{
            return[];
        }
    }
    func removeAllPj(){
        do{
            try self.dbPool.write { (db) -> Void in
                try? db.execute(sql: "delete from pj")
            }
        }catch let error as DatabaseError{
            print("write error:"+error.description)
        }catch{
            
        }
    }
    
    func saveQs(model:QianshouModel){
        do{
            try self.dbPool.write { (db) -> Void in
                try? db.execute(sql: "insert into qs(ydh,qsr,tp,bz,ts) values(:ydh,:qsr,:tp,:bz,:ts)", arguments: [
                    "ydh":model.billCode,
                    "qsr":model.signName,
                    "tp":model.tp,
                    "bz":model.signRemark,
                    "ts":model.signDate
                    ])
            }
        }catch let error as DatabaseError{
            print("write error:"+error.description)
        }catch{
            
        }
    }
    
    func deleteQs(model:QianshouModel){
        do{
            try self.dbPool.write { (db) -> Void in
                try? db.execute(sql: "delete from qs where ydh=:ydh", arguments: ["ydh":model.billCode])
            }
        }catch let error as DatabaseError{
            print("write error:"+error.description)
        }catch{
            
        }
    }
    
    func allQs() -> [QianshouModel]{
        do{
            return try self.dbPool.read { (db) -> [QianshouModel] in
                return try Row.fetchAll(db, sql: "select * from qs").map(QianshouModel.init)
                }.reversed()
        }catch{
            return[];
        }
    }
    
    func removeAllQs(){
        do{
            try self.dbPool.write { (db) -> Void in
                try? db.execute(sql: "delete from qs")
            }
        }catch let error as DatabaseError{
            print("write error:"+error.description)
        }catch{
            
        }
    }
    
    func saveWtj(model:WentijianModel){
        do{
            try self.dbPool.write { (db) -> Void in
                try? db.execute(sql: "insert into wtj(ydh,wtlx,tzzd,wtyy) values(:ydh,:wtlx,:tzzd,:wtyy)", arguments: [
                    "ydh":model.billCode,
                    "wtlx":model.problemType,
                    "tzzd":model.sendSite,
                    "wtyy":model.problemReasion
                    ])
            }
        }catch let error as DatabaseError{
            print("write error:"+error.description)
        }catch{
            
        }
    }
    
    func deleteWtj(model:WentijianModel){
        do{
            try self.dbPool.write { (db) -> Void in
                try? db.execute(sql: "delete from wtj where ydh=:ydh", arguments: ["ydh":model.billCode])
            }
        }catch let error as DatabaseError{
            print("write error:"+error.description)
        }catch{
            
        }
    }
    
    func allWtj() -> [WentijianModel]{
        do{
            return try self.dbPool.read { (db) -> [WentijianModel] in
                return try Row.fetchAll(db, sql: "select * from wtj").map(WentijianModel.init)
                }.reversed()
            
        }catch{
            return[];
        }
    }
    
    func removeAllWtj(){
        do{
        try self.dbPool.write { (db) -> Void in
            try? db.execute(sql: "delete from wtj")
        }
        }catch let error as DatabaseError{
            print("write error:"+error.description)
        }catch{
            
        }
    }
    
}

extension ShoujianModel{
    init(row:Row){
        self.init(
//            billCode: row.value(named: "ydh"),
//            recMan:row.value(named: "sjy"),
//            scanDate:row.value(named:"ts")
            billCode: row["ydh"],
            recMan: row["sjy"],
            scanDate: row["ts"]
        )
    }
}

extension FajianModel{
    init(row:Row){
        self.init(
//            billCode:row.value(named: "ydh"),
//            preOrNext:row.value(named: "zd"),
//            scanDate:row.value(named: "ts"),
            
            billCode: row["ydh"],
            preOrNext: row["zd"],
            scanDate: row["ts"],
            classs:"汽运"
        )
    }
}

extension DaojianModel{
    init(row:Row){
        self.init(
//            billCode:row.value(named: "ydh"),
//            preOrNext:row.value(named: "zd"),
//            scanDate:row.value(named: "ts")
            billCode:row["ydh"],
            preOrNext:row["zd"],
            scanDate:row["ts"]
        )
    }
}

extension PaijianModel{
    init(row:Row){
        self.init(
            billCode:row["ydh"],
            dispMan:row["pjy"],
            scanDate:row["ts"]
        )
    }
}

extension QianshouModel{
    init(row:Row){
        self.init(
            billCode:row["ydh"],
            signName:row["qsr"],
            tp:row["tp"],
            signRemark:row["bz"],
            signDate:row["ts"]
        )
    }
}

extension WentijianModel{
    init(row:Row){
        self.init(
            billCode:row["ydh"],
            problemType:row["wtlx"],
            sendSite:row["tzzd"],
            problemReasion:row["wtyy"]
        )
    }
}
