//
//  QRCodeReaderView.swift
//  QRCodeReader
//
//  Created by yunchou on 16/6/21.
//  Copyright © 2016年 aixin. All rights reserved.
//

import UIKit
import AVFoundation
public protocol QRCodeReaderViewDelegate:NSObjectProtocol {
    func onQrCodeReaderSuccess(qrview:QRCodeReaderView,code:String)
    func onQrCodeReaderFail(qrview:QRCodeReaderView)
    func onQrCodeReaderAccessRequired(qrview:QRCodeReaderView)
    func onQrCodeReaderCancel(qrview:QRCodeReaderView)
}

public class QRCodeReaderView: UIView {
    var overlayView:QRCodeReaderViewDefaultOverlayView? {
        willSet{
            self.overlayView?.removeFromSuperview()
        }
        didSet{
            guard let ov = self.overlayView else{return}
            self.insertSubview(ov, belowSubview: self.cancelBtn)
        }
    }
    var cancelBtn:UIButton!
    weak var delegate:QRCodeReaderViewDelegate?
    var previewLayer:AVCaptureVideoPreviewLayer?
    var captureSession:AVCaptureSession?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    public required  init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        if let ov = self.overlayView{
            ov.frame = self.bounds
        }
        if let vl = self.previewLayer{
            vl.frame = self.bounds
        }
        self.cancelBtn.sizeToFit()
        self.cancelBtn.frame = CGRect (x: 16, y: 36, width: self.cancelBtn.frame.width, height: self.cancelBtn.frame.height)
    }
    private func commonInit(){
        self.cancelBtn = UIButton()
        self.cancelBtn.setImage(UIImage(named: "qr_code_back"), for: UIControl.State.normal)
        self.cancelBtn.addTarget(self, action: #selector(onCancelBtnClicked), for: UIControl.Event.touchUpInside)
        self.addSubview(self.cancelBtn)
    }
    @objc private func onCancelBtnClicked(){
        delegate?.onQrCodeReaderCancel(qrview: self)
    }
    private func doReading(){
        do{
            
            self.previewLayer?.removeFromSuperlayer()
            self.overlayView?.onQrCodeReaderScanStart()
            let device = AVCaptureDevice.default(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video)))
            let input = try AVCaptureDeviceInput(device: device!)
            let output = AVCaptureMetadataOutput()
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            self.captureSession = AVCaptureSession()
            self.captureSession?.sessionPreset = AVCaptureSession.Preset(rawValue: convertFromAVCaptureSessionPreset(AVCaptureSession.Preset.high))
            self.captureSession?.addInput(input)
            self.captureSession?.addOutput(output)
            output.metadataObjectTypes = output.availableMetadataObjectTypes
            let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
            previewLayer.videoGravity = AVLayerVideoGravity(rawValue: convertFromAVLayerVideoGravity(AVLayerVideoGravity.resizeAspectFill))
            self.layer.insertSublayer(previewLayer, at: 0)
            self.previewLayer = previewLayer
            self.captureSession?.startRunning()
        }catch{
            NSLog("\(error)")
            self.delegate?.onQrCodeReaderFail(qrview: self)
        }
    }
    public func startReading(){
        if self.captureSession != nil { return }
        AVCaptureDevice.requestAccess(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video)), completionHandler: { [weak self](access) in
            guard let strongself = self else{ return }
            if access{
                DispatchQueue.main.async(execute: {
                    strongself.doReading()
                })
            }else{
                strongself.delegate?.onQrCodeReaderAccessRequired(qrview: strongself)
            }
        })
    }
    public func stopReading(){
        if self.captureSession == nil {return}
        self.captureSession?.stopRunning()
        self.captureSession = nil
        self.overlayView?.onQrCodeReaderScanStop()
    }
}
extension QRCodeReaderView:AVCaptureMetadataOutputObjectsDelegate{
    public func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        metadataObjects.forEach { (o) in
            if let m = o as? AVMetadataMachineReadableCodeObject{
                self.stopReading()
                NSLog("read code:\(m.stringValue)")
                delegate?.onQrCodeReaderSuccess(qrview: self, code: m.stringValue!)
            }
        }
    }
}
public class QRCodeReaderViewDefaultOverlayView: UIView {
    private var scanRectView:QRCodeReaderScanRectView!
    private var remindLabel:UILabel!
    var fillLayer:CAShapeLayer!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    public required  init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    private func makeRemindAttributeString() -> NSAttributedString{
        let str1 = NSMutableAttributedString(string: "")
        return str1
    }
    private func commonInit(){
        scanRectView = QRCodeReaderScanRectView()
        self.addSubview(scanRectView)
        fillLayer = CAShapeLayer()
        fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
        fillLayer.fillColor = UIColor(white: 0.0, alpha: 0.8).cgColor
        fillLayer.opacity = 1.0
        self.layer.addSublayer(fillLayer)
        remindLabel = UILabel()
        remindLabel.textColor = UIColor.white
        remindLabel.font = UIFont.systemFont(ofSize: 12)
        remindLabel.numberOfLines = 0
        remindLabel.textAlignment = .center
        remindLabel.attributedText = self.makeRemindAttributeString()
        self.addSubview(self.remindLabel)
    }
    private func rebuildFillLayerPath(){
        let path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 0)
        let maskPath = UIBezierPath(roundedRect: scanRectView.frame, cornerRadius: 0)
        path.append(maskPath)
        path.usesEvenOddFillRule = true
        fillLayer.path = path.cgPath
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        let height:CGFloat = 200
        scanRectView.frame = CGRect(x: 0, y: (frame.height - height) / 2, width: frame.width, height: height)
        remindLabel.sizeToFit()
        remindLabel.frame = CGRect(x: (frame.width - remindLabel.frame.width) / 2, y: scanRectView.frame.maxY + 40, width: remindLabel.frame.width, height: remindLabel.frame.height)
        self.rebuildFillLayerPath()
    }
    func onQrCodeReaderScanStart(){
        scanRectView.startAnimation()
    }
    func onQrCodeReaderScanStop(){
        scanRectView.stopAnimation()
    }
}
private class QRCodeReaderScanRectView:UIView{
    var lineView:QRCodeReaderScanAnimationLineView!
    var animationRuning = false
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    private func commonInit(){
        lineView = QRCodeReaderScanAnimationLineView()
        lineView.backgroundColor = UIColor.red
        self.addSubview(lineView)
    }
    func startAnimation(){
        self.animationRuning = true
        self.addLineAnimation()
    }
    func stopAnimation(){
        self.animationRuning = false
    }
    private func addLineAnimation(){
        UIView.animate(withDuration: 0.1, animations: {
            [weak self] in
            guard let stongself = self else{ return }
            if stongself.lineView.alpha == 0{
                stongself.lineView.alpha = 1
            }else if stongself.lineView.alpha == 1{
                stongself.lineView.alpha = 0
            }
        }) { [weak self](finish) in
            guard let stongself = self else{ return }
            if finish && stongself.animationRuning{
                stongself.addLineAnimation()
            }
        }
    }
    fileprivate override func layoutSubviews() {
        super.layoutSubviews()
        lineView.frame = CGRect(x: 0, y: frame.height / 2, width: self.frame.width, height: 0.5)
    }
}
private class QRCodeReaderScanAnimationLineView:UIView{
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMediaType(_ input: AVMediaType) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVCaptureSessionPreset(_ input: AVCaptureSession.Preset) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVLayerVideoGravity(_ input: AVLayerVideoGravity) -> String {
	return input.rawValue
}
