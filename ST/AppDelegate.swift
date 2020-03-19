//
//  AppDelegate.swift
//  ST
//
//  Created by yunchou on 2016/10/24.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,BNNaviSoundDelegate{
	
	
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		self.window?.tintColor = UIColor.appMajor
		self.setupNavbar()
		self.setupBaiDuMap()
		
		
		UIViewController.hook()
		self.loadInitDatas { success in
			UIAlertView.remindUser(success ? "初始化数据成功":"初始化数据失败，请稍后重试")
		}
		let window = UIWindow(frame: UIScreen.main.bounds)
		#if DEBUG
		window.rootViewController =  TinyConsoleController(rootViewController: ViewController())
		TinyConsole.print("hello")
		#else
		window.rootViewController = ViewController()
		#endif
		window.makeKeyAndVisible()
		self.window = window
		return true
	}
	
	private func loadInitDatas(complete:@escaping (Bool) -> Void){
		DataManager.shared.loadInitData(forthNet: true, complete: complete)
	}
	
	
	func applicationWillResignActive(_ application: UIApplication) {
	}
	func applicationDidEnterBackground(_ application: UIApplication) {
	}
	func applicationWillEnterForeground(_ application: UIApplication) {
	}
	func applicationDidBecomeActive(_ application: UIApplication) {
	}
	func applicationWillTerminate(_ application: UIApplication) {
	}
	
	func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		self.loadInitDatas { success in
			print("back ground fetch complete:\(success)")
			completionHandler(success ? .newData:.failed)
		}
	}
	
	//MARK:- setup base ui
	func setupNavbar(){
		UINavigationBar.appearance().tintColor = UIColor.white
		UINavigationBar.appearance().barTintColor = UIColor.appBlue
		UINavigationBar.appearance().backgroundColor = UIColor.appBlue
		UINavigationBar.appearance().titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.foregroundColor.rawValue: UIColor.white])
	}

	
	//MARK:- init third library
	func setupBaiDuMap(){
		BNaviService.getInstance()?.initNaviService(nil, success: {
			BNaviService.getInstance()?.authorizeNaviAppKey(Consts.BDNaviAK, completion: { [unowned self] (result) in
				if(result){
					print("authorizeNaviAppkey success....")
				}else{
					print("authorizeNaviAppkey failed....")
				}
			})
			
			BNaviService.getInstance()?.authorizeTTSAppId("appid", apiKey: Consts.BDAIAK, secretKey: Consts.BDAISK, completion: { (result) in
				print("语音授权成功...")
			})
			BNaviService.getInstance()?.soundManager()?.setSoundDelegate(self)
			
		}) {
			
		}
		
	}
	
	
	//MARK:- BNNaviSoundDelegate
	/**
	*  播报或进入导航的时候都会检测TTS是否鉴权成功
	*  (1)如果还没鉴权成功，会尝试先鉴权，然后回调鉴权结果，
	*  (2)如果已经鉴权成功，也会回调鉴权成功
	*/
	func onTTSAuthorized(_ success: Bool) {
		if(success){
			print("播报authorize failed")
		}else{
			print("播报authorize success")
		}
	}
	
	
	/**
	*  TTS文本回调
	*/
	func onPlayTTS(_ text: String!) {
		print("onPlayTTSonPlayTTSonPlayTTSonPlayTTS")
	}
	
	func onPlay(_ type: BNVoiceSoundType, filePath: String!) {
		print("onPlayonPlayonPlayonPlay")
	}
	
	
	
}





// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
