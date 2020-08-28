//
//  AppDelegate.swift
//  ST
//
//  Created by yunchou on 2016/10/24.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
	
	
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		self.window?.tintColor = UIColor.appMajor
		self.setupNavbar()
		
		
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
		ConnecterManager.sharedInstance()?.close()
		HPrinterHelper.sharedInstance().disconnectCurrentPrinter();
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

}





// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
