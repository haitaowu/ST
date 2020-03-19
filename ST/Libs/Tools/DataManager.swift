//
//  DataManager.swift
//  ST
//
//  Created by yunchou on 2016/11/5.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit
import Dispatch
import HandyJSON

typealias SaveCompleteCallback = (_ success:Bool,_ msg:String) -> Void
class DataManager{
    static let shared = DataManager()
    private var async = Async()
    private var db = UserDefaults(suiteName: "initdata")!
//    var roleType:RoleType = RoleType.center
	//是否有用户登录过
	func hasLogined() -> Bool {
		if let roleType: RoleType = self.roleType{
			if roleType == .none{
				return false
			}else{
				return true
			}
		}else{
			return false
		}
	}
	
	var roleType:RoleType?{
		get{
			let type = UserDefaults.standard.object(forKey: "roleType")
			if let rType = type as? String{
				if rType == RoleType.center.rawValue{
					return .center
				}else if rType == RoleType.driver.rawValue{
					return .driver
				}else if rType == RoleType.site.rawValue{
					return .site
				}else{
					return .none
				}
			}else{
				return .none
			}
		}
		set{
			let userDefault = UserDefaults.standard
			if let typeValue = newValue{
				userDefault.set(typeValue.rawValue, forKey: "roleType")
			}else{
				userDefault.set(nil, forKey: "roleType")
			}
			userDefault.synchronize()
		}
	}
    
    var addressPickerModel:AddressPickerModel = AddressPickerModel(){
        didSet{
            db["citys"] = DbObject(value: addressPickerModel).encode()
        }
    }
		///中心、网点账号
    var loginUser:User{
        get{
            let data = db["loginUser"].data
            if let m:User = User.decode(data: data){
                return m
            }
            return User()
        }
        set{
            if let data = newValue.encode(){
                db["loginUser"] = data
            }
        }
    }
	
	var loginDriver:DriverModel{
		get{
			let data = db["loginDriver"].data
			if let m:DriverModel = DriverModel.decode(data: data){
				return m
			}
			return DriverModel()
		}
		set{
			if let data = newValue.encode(){
				db["loginDriver"] = data
			}
		}
	}
	
	
    var citys:[City] = []{
        didSet{
            db["citys"] = DbObject(value: citys).encode()
        }
    }
    var transferTypes:[TransferType] = []{
        didSet{
            db["transferTypes"] = DbObject(value: transferTypes).encode()
        }
    }
    var customers:[Customer] = []{
        didSet{
            db["customers"] = DbObject(value: customers).encode()
        }
    }
    var employees:[Employee] = []{
        didSet{
            db["employees"] = DbObject(value: employees).encode()
        }
    }
    var problemItemReasons:[ProblemItemReason] = []{
        didSet{
            db["problemItemReasons"] = DbObject(value: problemItemReasons).encode()
        }
    }
    var sites:[SiteInfo] = []{
        didSet{
            db["sites"] = DbObject(value: sites).encode()
        }
    }
    
    
    func loadInitData(forthNet:Bool = false,complete:@escaping ((Bool) -> Void)){
        if forthNet{
            self.loadInitDataNet(complete: complete)
        }else{
            self.loadInitDataLocal(complete: { (success) in
                if !success{
                    self.loadInitDataNet(complete: complete)
                }else{
                    complete(true)
                }
            })
        }
    }
    private func loadInitData<T:SimpleCodable>(key:String) -> T?{
        let data = self.db[key].data
        if let dbObject:DbObject<T> = DbObject<T>.decode(data: data){
            return dbObject.value
        }
        return nil
    }
    func loadInitDataLocal(complete:@escaping ((Bool) -> Void)){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            if let citys:[City] = self.loadInitData(key: "citys"){
                self.citys = citys
            }
            if let transferTypes:[TransferType] = self.loadInitData(key: "transferTypes"){
                self.transferTypes = transferTypes
            }
            if let customers:[Customer] = self.loadInitData(key: "customers"){
                self.customers = customers
            }
            if let employees:[Employee] = self.loadInitData(key: "employees"){
                self.employees = employees
            }
            if let problemItemReasons:[ProblemItemReason] = self.loadInitData(key: "problemItemReasons"){
                self.problemItemReasons = problemItemReasons
            }
            if let sites:[SiteInfo] = self.loadInitData(key: "sites"){
                self.sites = sites
            }
            DispatchQueue.main.async{ complete(true) }
        }
    }
    
    func loadInitDataNet(complete:@escaping ((Bool) -> Void)){
        self.async = Async()
        _ = self.async.task("load cities").execute { (task) in
            STNetworking<[City]>(stRequest: CityLoadRequest()) { resp in
                DataManager.shared.citys = resp.data
                task.complete(success: true)
                NSLog("load cities comoplete")
            }?.resume()
        }
        _ = self.async.task("load transfertypes").execute { (task) in
            STNetworking<[TransferType]>(stRequest: TransferTypeLoadRequest()) { resp in
                DataManager.shared.transferTypes = resp.data
                task.complete(success: true)
                NSLog("load transfertypes comoplete")
            }?.resume()
        }
        
        _ = self.async.task("load customers").execute({ (task) in
            STNetworking<[Customer]>(stRequest: CustomerLoadRequest()) { resp in
                DataManager.shared.customers = resp.data
                task.complete(success: true)
                NSLog("load customers comoplete")
            }?.resume()
        })
        
        _ = self.async.task("load employees").execute({ (task) in
            STNetworking<[Employee]>(stRequest: EmployeeLoadRequest()) { resp in
                DataManager.shared.employees = resp.data
                task.complete(success: true)
                NSLog("load employees comoplete")
            }?.resume()
        })
        
        
        _ = self.async.task("load problems").execute({ (task) in
            STNetworking<[ProblemItemReason]>(stRequest: ProblemItemReasonLoadRequest()) { resp in
                DataManager.shared.problemItemReasons = resp.data
                task.complete(success: true)
                NSLog("load problems comoplete")
            }?.resume()
        })
        
        _ = self.async.task("load sites").execute({ (task) in
            STNetworking<[SiteInfo]>(stRequest: SiteInfoLoadRequest()) { resp in
                DataManager.shared.sites = resp.data
                task.complete(success: true)
                NSLog("load sites comoplete")
            }?.resume()
        })
        _ = self.async.task("load address picker").execute({ (task) in
            UrlSessioinNetworking(request: AddressModelRequest(), onResponse: { (resp) in
                if let data = resp.data, let str = String(data: data, encoding: String.Encoding.utf8),let provincesList = JSONDeserializer<AddressPickerProvince>.deserializeModelArrayFrom(json: str){
                    DataManager.shared.addressPickerModel = AddressPickerModel(provincesList: provincesList.compactMap{ $0 }, selectProvinceIndex: 0)
                }
                 NSLog("load address comoplete")
                task.complete(success: true)
            })?.resume()
        })
        self.async.run { (tasks) in
            complete(true)
        }
    }
    func saveShouJian(m:ShoujianModel){
        STDb.shared.saveSj(model: m)
        //self.uploadShoujian(m: [m])
    }
    func uploadShoujian(m:[ShoujianModel],callback:SaveCompleteCallback? = nil){
        let req = ShoujianSaveRequest(obj: m)
        STNetworking<UploadResult>(stRequest:req){
            resp in
            callback?(resp.stauts == Status.Success.rawValue,resp.msg)
            NSLog("\(resp)")
        }?.resume()
    }
    func saveFaJian(m:FajianModel){
        STDb.shared.saveFj(model: m)
        //self.uploadFajian(m:[m])
    }
    func uploadFajian(m:[FajianModel],callback:SaveCompleteCallback? = nil){
        let req = FajianSaveRequest(obj: m)
        STNetworking<UploadResult>(stRequest:req){
            resp in
            callback?(resp.stauts == Status.Success.rawValue,resp.msg)
            NSLog("\(resp)")
        }?.resume()
    }
    func saveDaojian(m:DaojianModel){
        STDb.shared.saveDj(model: m)
        //self.uploadDaojian(m: [m])
    }
    func uploadDaojian(m:[DaojianModel],callback:SaveCompleteCallback? = nil){
        let req = DaojianSaveRequest(obj: m)
        STNetworking<UploadResult>(stRequest:req){
            resp in
            callback?(resp.stauts == Status.Success.rawValue,resp.msg)
            NSLog("\(resp)")
        }?.resume()
    }
    func savePijian(m:PaijianModel){
        STDb.shared.savePj(model: m)
        //self.uploadPaijian(m:[m])
    }
    func uploadPaijian(m:[PaijianModel],callback:SaveCompleteCallback? = nil){
        let req = PaijianSaveRequest(obj: m)
        STNetworking<UploadResult>(stRequest:req){
            resp in
            callback?(resp.stauts == Status.Success.rawValue,resp.msg)
            NSLog("\(resp)")
        }?.resume()
    }
	
    func saveQianshou(m:QianshouModel){
        STDb.shared.saveQs(model: m)
        //self.uploadQianshou(m: [m])
    }
    
//    func uploadQianshou(m:[QianshouModel],callback:SaveCompleteCallback? = nil){
//        let images = m.map{ $0.tp }.filter{ !$0.isEmpty }
//        self.uploadQianshouImages(images: images){
//            let req = QianshouSaveRequest(obj: m)
//            STNetworking<UploadResult>(stRequest:req){
//                resp in
//                callback?(resp.stauts == Status.Success.rawValue,resp.msg)
//                NSLog("\(resp)")
//            }?.resume()
//        }
//    }
    
    func reqBillQianshou(m:[QianshouModel],callback:SaveCompleteCallback? = nil){
        let images = m.map{ $0.tp }.filter{ !$0.isEmpty }
        let req = QianshouSaveRequest(obj: m)
        STNetworking<UploadResult>(stRequest:req){
            resp in
            if(resp.stauts == Status.Success.rawValue){
                self.uploadQianshouImages(images: images){
                    NSLog("upload image success")
                }
            }
            callback?(resp.stauts == Status.Success.rawValue,resp.msg)
            NSLog("sign response == \(resp)")
            }?.resume()
    }
    
    func saveWentijian(m:WentijianModel){
        STDb.shared.saveWtj(model: m)
        //self.uploadWentijian(m: [m])
    }
    func uploadWentijian(m:[WentijianModel],callback:SaveCompleteCallback? = nil){
        let req = WentijianSaveRequest(obj: m)
        STNetworking<UploadResult>(stRequest:req){
            resp in
            callback?(resp.stauts == Status.Success.rawValue,resp.msg)
            NSLog("\(resp)")
        }?.resume()
    }
    
    func uploadQianshouImages(images:[String],complete:@escaping () -> Void){
        let target = "/AndroidService/pic/uploadSignPic.do"
        self.uploadImages(target: target, images: images, complete: complete)
    }
    
    func uploadImages(target:String,images:[String],complete:@escaping () -> Void){
        self.async = Async()
        images.forEach{
            filename in
            _ = self.async.task(filename).execute({ (task) in
                let filePath = NSHomeDirectory().appending("/Documents/\(filename)")
                self.fileUpload(target: target, filePath: filePath, complete: {
                    task.complete(success: true)
                })
            })
        }
        self.async.run { tasks in
            complete()
        }
    }
    private func fileUpload(target:String,filePath:String,complete:@escaping () -> Void){
        let req = STImageUploadRequest(target: target, imagePath: filePath)
        UrlSessioinNetworking(request: req){
            resp in
            complete()
        }?.resume()
        
    }
    func saveLocalImage(img:UIImage,ydh:String,complete:(String) -> Void){
        let filename = ydh + "_" + NSUUID().uuidString + ".jpg"
        let filePath = NSHomeDirectory().appending("/Documents/\(filename)")
        if let data = img.compressImage(maxLength: 1024 * 100){
            let url = URL(fileURLWithPath: filePath)
            do{
                try data.write(to: url)
                complete(filename)
            }catch{
                complete("")
            }
        }else{
            complete("")
        }
    }
}
