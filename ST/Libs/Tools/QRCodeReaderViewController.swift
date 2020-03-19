//
//  QRCodeReaderViewController.swift
//  QRCodeReader
//
//  Created by yunchou on 16/6/21.
//  Copyright © 2016年 aixin. All rights reserved.
//

import UIKit

class QRCodeReaderViewController: UIViewController {
    var readerView:QRCodeReaderView!
    weak var delegate:QRCodeReaderViewDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.readerView = QRCodeReaderView()
        self.readerView.delegate  = self.delegate
        self.readerView.overlayView = QRCodeReaderViewDefaultOverlayView()
        self.view.addSubview(self.readerView)
        self.readerView.startReading()
    }
    deinit{
        self.readerView.stopReading()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        self.navigationController?.isNavigationBarHidden = false
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.readerView.frame = self.view.bounds
    }
    
}

