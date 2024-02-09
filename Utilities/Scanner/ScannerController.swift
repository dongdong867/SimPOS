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
                    self.setCaptureDevice()
                    self.setPreviewLayer()
                    DispatchQueue.main.async {
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
            completion(.failure(.notFound))
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(videoInput)
        } catch let error {
            completion(.failure(.customError(error)))
        }
            
        let metadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(metadataOutput)
        metadataOutput.metadataObjectTypes = [.code128, .code39, .qr, .upce, .ean8, .ean13]
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
    }
    
    func setPreviewLayer() {
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspect
        view.layer.addSublayer(previewLayer)
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
}

enum ScannerError: Error {
    case accessDenied, accessRestricted
    case notFound
    case unknown, customError(Error)
    
    func description() -> String {
        switch self {
            case .accessDenied:
                "Camera access denied."
            case .accessRestricted:
                "Camera access restricted."
            case .notFound:
                "Camera not found."
            case .unknown:
                "Unknown error occurred."
            case .customError(let error):
                error.localizedDescription
        }
    }
}
