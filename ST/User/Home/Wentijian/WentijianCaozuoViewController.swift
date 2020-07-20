//
//  WentijianCaozuoViewController.swift
//  ST
//
//  Created by yunchou on 2016/10/29.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit
import Alamofire



class WentijianCaozuoViewController: UIViewController,STListViewDelegate,QrInterface,PickerInputViewModelDelegate,WangdianPickerInterface ,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var objects:[STListViewModel] = []
    @IBOutlet weak var ydhField: UITextField!
    @IBOutlet weak var wtlxField: UITextField!
    @IBOutlet weak var tzzdField: UITextField!
    @IBOutlet weak var wtyyField: UITextField!
    @IBOutlet weak var pickImageView: UIButton!
    
    let reasonPicker:PickerInputView = Bundle.main.loadNibView(name: "PickerInputView")
    var reasonModel = ProblemItemReasonsViewModel()
    var headers:[String] = ["运单号","类型"]
    var columnPercents:[CGFloat] = [0.5,0.5]
    var proImg:UIImage?
    
    var selectedReason:ProblemItemReason?;
    
    @IBOutlet weak var listView: STListView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.appBgColor
        self.title = "问题件操作"
        self.listView.styleme()
        self.listView.delegate = self
        self.reloadData()
        reasonModel.problems = DataManager.shared.problemItemReasons
        reasonPicker.model = reasonModel
        reasonPicker.delegate = self
        wtlxField.inputView = reasonPicker
//        self.setupUploadNavItem()
        // Do any additional setup after loading the view.
    }
    
    
    func deleteObject(object:STListViewModel) -> Bool{
        if let object = object as? WentijianModel{
            STDb.shared.deleteWtj(model: object)
            self.objects = self.objects.filter{ ($0 as! WentijianModel).billCode != object.billCode }
            return true
        }
        return false
    }

    
    func onWangdianPicked(item: SiteInfo) {
        self.tzzdField.text = item.siteName
    }
   
    func onPickerInputViewRequestDismiss(){
        self.wtlxField.resignFirstResponder()
    }
    private func reloadData(){
        self.objects = STDb.shared.allWtj()
        self.listView.reloadData()
    }
    
    func onReadQrCode(code: String) {
        self.ydhField.text = code
    }
    
    //MARK:- Reason PickerInputViewModelDelegate
    //Textfield 问题类型 代理 onPickerInputViewIndexChagne
    func onPickerInputViewIndexChagne(_ row:Int,_ component:Int){
        if row < self.reasonModel.problems.count{
            self.wtlxField.text = reasonModel.problems[row].problem
            self.selectedReason = reasonModel.problems[row];
        }
    }
    
    //MARK:- UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) { 
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.proImg = img;
            self.pickImageView.setBackgroundImage(img , for: .normal);
        }
        picker.dismiss(animated: true) {
        }
    }
    
    //MARK:- UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        NSLog("click at \(buttonIndex)");
        if buttonIndex == 1 {
            self.pickImageByCamera();
        }else if(buttonIndex == 2){
            self.pickImageByPhotoLibrary();
        }
    }
	
    //MARK:- private methods
    // convert UIImage to NSString
//    func stringForImage(img: UIImage) -> String? {
//        let data = UIPng
//    }
    
//    func timeStrWith(format:String) -> String{
//        let dateFormat = DateFormatter.init();
//        dateFormat.dateFormat = format;
//        let date:Date = Date();
//        let dateStr = dateFormat.string(from: date);
//        return dateStr;
//    }
    
    ///selected reason should pick image
	func shouldPickImg() -> Bool{
		if let reason = self.selectedReason{
            //地址不详-1  异常到件-2 客户要求重新派送-9
            if (reason.problemCode == "1") || (reason.problemCode == "2") || (reason.problemCode == "9") || (reason.problemCode == "22x"){
                return true
            }else{
                return false
            }
        }else{
			return false
        }
	}
	
	
	//ya suo tupian
    func compressImageStringFor(img :UIImage?) -> String? {
        guard let image = img else {
            return nil;
        }
        let compressedImgData = image.compressImage( maxKB: 50);
        if let data = compressedImgData {
            let count = data.count / 1024;
            NSLog( "size of image = \(count) KB");
            let string = data.base64EncodedString(options: .lineLength64Characters);
            //以下两种方式编码的字符串结果相同
           //1.
//            let string = data.base64EncodedString();
            //2.
//            let string = data.base64EncodedString(options: .endLineWithLineFeed);
            return string
        }else{
            return nil;
        }
    }
    
   //通过相机选择图片
    func pickImageByCamera(){
		if(UIImagePickerController.isSourceTypeAvailable(.camera)){
			let imgPicker = UIImagePickerController.init();
			imgPicker.allowsEditing = true;
			imgPicker.sourceType = .camera
			imgPicker.cameraFlashMode = .off
			imgPicker.delegate = self;
			self.present(imgPicker, animated: true) {
				NSLog("presentcamera ImagePicker completion ...")
			}
		}else{
			print("相机不可用")
		}
	}
    
   //通过相册选择图片
    func pickImageByPhotoLibrary(){
		if(UIImagePickerController.isSourceTypeAvailable(.camera)){
			let imgPicker = UIImagePickerController();
			imgPicker.allowsEditing = true;
			imgPicker.sourceType = .photoLibrary;
			imgPicker.delegate = self;
			self.present(imgPicker, animated: true) {
				NSLog("presentPhotoLibrary ImagePicker completion ...")
			}
		}else{
			print("相册不可用")
		}
    }
    
    
    
    //tap gesture
    @IBAction func tapOnView(_ sender: Any) {
        self.view.endEditing(true);
    }
    
    @IBAction func scanBtnClicked(_ sender: Any) {
        self.openQrReader()
    }
    
    //MARK:- selectors
    //选择网点
    @IBAction func wangdianXuanzeBtnClicked(_ sender: Any) {
        self.showWangdianPicker()
    }
    
    
    @IBAction func tapPickImageBtn(_ sender: Any) {
        let ydh = self.ydhField.text ?? ""
        if  ydh.isEmpty{
            self.remindUser(msg: "运单号不能为空")
            return;
        }
		
		if self.shouldPickImg(){
			let actionControl = UIAlertController(title: "选择方式", message: nil, preferredStyle: .actionSheet)
			actionControl.addAction(UIAlertAction(title: "相机", style: UIAlertAction.Style.default, handler: {[unowned self] (action) in
			  self.pickImageByCamera()
			}))
			
			actionControl.addAction(UIAlertAction(title: "相册", style: UIAlertAction.Style.default, handler: { [unowned self] (action) in
			  self.pickImageByPhotoLibrary()
			}))
			
			actionControl.addAction(UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: { (action) in
			  
			}))
			
			self.present(actionControl, animated: true, completion: {
			})
			
//			let sheetView = UIActionSheet(title: "选择图片", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil);
//			sheetView.addButton(withTitle: "相机");
//			sheetView.addButton(withTitle: "相册");
//			sheetView.show(in: self.view)
		}else{
			self.remindUser(msg: "选择的问题类型不能上传图片")
		}
		
		/*
        if let reason = self.selectedReason{
            //地址不详-1  异常到件-2 客户要求重新派送-9
            if (reason.problemCode == "1") || (reason.problemCode == "2") || (reason.problemCode == "9") || (reason.problemCode == "22x"){
                let sheetView = UIActionSheet(title: "选择图片", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil);
                sheetView.addButton(withTitle: "相机");
                sheetView.addButton(withTitle: "相册");
                sheetView.show(in: self.view);
            }else{
                self.remindUser(msg: "选择的问题类型不能上传图片")
            }
        }else{
            self.remindUser(msg: "问题类型不能为空")
        }
		*/
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        let ydh = self.ydhField.text ?? ""
        let wtlx = self.wtlxField.text ?? ""
        let tzzd = self.tzzdField.text ?? ""
        let wtyy = self.wtyyField.text ?? ""
        
        if ydh.isEmpty{
            self.remindUser(msg: "运单号不能为空")
            return
        }
        if !ydh.isBarcode(){
            self.remindUser(msg: "运单号格式错误")
            return
        }
        if wtlx.isEmpty{
            self.remindUser(msg: "问题类型不能为空")
            return
        }
        if tzzd.isEmpty{
            self.remindUser(msg: "通知站点不能为空")
            return
        }
        if wtyy.isEmpty{
            self.remindUser(msg: "问题原因不能为空")
            return
        }
        
        let pic = self.compressImageStringFor(img: self.proImg);
        var problemParams: Parameters = [:];
		let timeStr = Date().dateStringFrom(dateFormat: "hhmmss")
        problemParams["ID"] =  timeStr
        problemParams["fileType"] =  "png"
        problemParams["BILL_CODE"] =  ydh
        problemParams["TYPE"] = wtlx
        problemParams["SEND_SITE"] = tzzd
        problemParams["PROBLEM_CAUSE"] = wtyy
        
        if pic != nil{
            problemParams["pic"] = pic
        }
        do {
            let valuesData = try JSONSerialization.data(withJSONObject: problemParams, options: .prettyPrinted);
            let problemString = String(data: valuesData, encoding: .utf8)
            let params: Parameters = ["problem":problemString!];
            self.submitProblemData(parameters: params);
        } catch {
            
        }
        let m = WentijianModel(billCode: ydh, problemType: wtlx, sendSite: tzzd, problemReasion: wtyy)
        DataManager.shared.saveWentijian(m: m)
        self.reloadData()
    }
	
    
    //MARK:- request server
    func submitProblemData(parameters: Parameters){
        self.showLoading(msg: "上传问题件...");
        let reqUrl = Consts.Server+Consts.BaseUrl+"m8/uploadProblemAndPicBase64.do"
        NSLog("parameters = \(parameters)");
        Alamofire.request(reqUrl, method: .post, parameters: parameters).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            self.hideLoading();
            if let json = response.result.value {
                print("result.value: \(json)") // serialized json response
            }
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)") // original server data as UTF8 string
            }
            
            if let json = response.result.value as? NSDictionary{
                if let stauts = json.value(forKey: "stauts"){
                    if let statusNum = stauts as? Int{
                        if statusNum == 4{
							STDb.shared.removeAllWtj()
                            self.remindUser(msg: "上传成功")
                        }else{
                            let msg = json.value(forKey: "msg") as? String
                            self.remindUser(msg: msg!)
                            NSLog("request product status = \(stauts)")
                        }
                    }
                }else{
                    self.remindUser(msg: "上传失败")
                }
            }else{
                self.remindUser(msg: "上传失败")
            }
        }
    }
    
}


