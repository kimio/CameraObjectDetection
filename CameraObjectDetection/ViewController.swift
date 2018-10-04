//
//  ViewController.swift
//  CameraObjectDetection
//
//  Created by Felipe Kimio Nishikaku on 16/09/18.
//  Copyright © 2018 Felipe Kimio Nishikaku. All rights reserved.
//

import UIKit
import AVKit
import Vision

extension ViewController {
    
    private func addLabel() {
        view.addSubview(informationLabel)
        let views: [String: UIView] = ["v0": informationLabel]
        ["V:[v0]-90-|","H:|-50-[v0]-50-|"].forEach { (visualFormat) in
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: visualFormat,
                                                               options: NSLayoutConstraint.FormatOptions(),
                                                               metrics: nil,
                                                               views: views))
        }
    }
}

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    var informationLabel: Label = {
        let label: Label = Label()
        label.numberOfLines = 5
        label.layer.cornerRadius = 8
        label.layer.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.layer.shadowOpacity = 0.5
        label.layer.shadowRadius = 10
        label.padding = 20
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let avCaptureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(avCaptureDeviceInput)
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.init(label: "videoQuee"))
        captureSession.addOutput(dataOutput)
        
        addLabel()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        //https://developer.apple.com/machine-learning/build-run-models/
        guard let mlModel = try? VNCoreMLModel(for: Resnet50().model) else { return }
        let request = VNCoreMLRequest(model: mlModel) { (finishedRequest, error) in
            
            guard let results = finishedRequest.results as? [VNClassificationObservation] else { return }
            guard let firstObservation = results.first else { return }
            DispatchQueue.main.async {
                self.informationLabel.text = "\(Int(firstObservation.confidence * 100))%\n\(firstObservation.identifier)"
            }
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}
