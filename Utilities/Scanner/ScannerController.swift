//
//  ScannerController.swift
//
//
//  Created by Dong on 2024/2/9.
//

import AVFoundation
import Foundation
import UIKit

class ScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession
    var previewLayer: AVCaptureVideoPreviewLayer
    var completion: (Result<String, ScannerError>) -> Void
    
    init(completion: @escaping (Result<String, ScannerError>) -> Void) {
        captureSession = AVCaptureSession()
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkAuthorizationStatus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.startSession()
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.captureSession.stopRunning()
        }
    }
    
    @objc
    func orientationChanged() {
//        switch UIDevice.current.orientation {
//            case UIDeviceOrientation.portraitUpsideDown:
//                self.previewLayer.connection?.videoRotationAngle = 180
//                
//            case UIDeviceOrientation.landscapeLeft:
//                self.previewLayer.connection?.videoRotationAngle = 90
//                
//            case UIDeviceOrientation.landscapeRight:
//                self.previewLayer.connection?.videoRotationAngle = -90
//            
//            default:
//                self.previewLayer.connection?.videoRotationAngle = 90
//        }
        
        switch UIDevice.current.orientation {
            case .portrait:
                self.previewLayer.connection?.videoOrientation = .portrait
            case .landscapeLeft:
                self.previewLayer.connection?.videoOrientation = .landscapeRight
            case .landscapeRight:
                self.previewLayer.connection?.videoOrientation = .landscapeLeft
            case .portraitUpsideDown:
                self.previewLayer.connection?.videoOrientation = .portraitUpsideDown
            default:
                return
        }
    }
    
    func checkAuthorizationStatus() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                setCaptureDevice()
                setPreviewLayer()
                startSession()
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { status in
                    guard status else {
                        self.completion(.failure(.accessDenied))
                        return
                    }
                    DispatchQueue.main.async {
                        self.setCaptureDevice()
                        self.setPreviewLayer()
                        self.startSession()
                    }
                }
            case .denied:
                completion(.failure(.accessDenied))
            case .restricted:
                completion(.failure(.accessRestricted))
            default:
                completion(.failure(.unknown))
        }
    }
    
    func setCaptureDevice() {
        guard let captureDevice = AVCaptureDevice.default(for: .video)
        else {
            completion(.failure(.deviceNotFound))
            return
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
                
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(videoInput)
        } catch let error {
            completion(.failure(.customError(error)))
        }
            
        let metadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(metadataOutput)
        metadataOutput.metadataObjectTypes = [.qr, .upce, .ean8, .ean13]
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
    }
    
    func setPreviewLayer() {
        previewLayer.frame = CGRect(x: 0, y: 0, width: getPreviewFrameSize(), height: getPreviewFrameSize())
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
    }
    
    func getPreviewFrameSize() -> CGFloat {
        if(view.frame.width > view.frame.height) {
            return min(view.frame.height, 500)
        } else {
            return min(view.frame.width, 500)
        }
    }
    
    func startSession() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let metadataObject = metadataObject as? AVMetadataMachineReadableCodeObject
            else { return }
            
            guard let result = metadataObject.stringValue
            else { return }
            
            completion(.success(result))
        }
    }
    
    enum ScannerError: Error, LocalizedError {
        case accessDenied, accessRestricted, deviceNotFound
        case unknown, customError(Error)
        
        func description() -> String {
            switch self {
                case .accessDenied:
                    "Camera access denied."
                case .accessRestricted:
                    "Camera access restricted."
                case .deviceNotFound:
                    "Camera not found."
                case .unknown:
                    "Unknown error occurred."
                case .customError(let error):
                    error.localizedDescription
            }
        }
    }
}
