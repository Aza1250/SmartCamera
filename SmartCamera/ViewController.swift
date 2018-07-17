//
//  ViewController.swift
//  SmartCamera
//
//  Created by Aziz Zaynutdinov on 7/17/18.
//  Copyright © 2018 Aziz Zaynutdinov. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //here is where we start up the camera
        
        //first, create a session for the recording of video or audio
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        //here we specify the capture device as default video (back camera)
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        //we need to get out of the scope of the guard statement using any of the following: continue, break, throw, return.
        
        //this is a capture input that provides media from a capture device (captureDevice) to a capture session (captureSession)
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return } //return keyword here is used to exit the scope of the guard statement
        
        //second, add any input deviced to capture with. this could be an mic or the back camera of your phone
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        //here is a core animation layer that can display video as it is being captured.
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        //we add that previewLayer to the list of all layers of the view (we add a Sublayer)
        view.layer.addSublayer(previewLayer)
        //we display the preview layer
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        //we want to monitor each frame with this dataOutput
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Video queue"))
        captureSession.addOutput(dataOutput)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedRequest, error) in
            //check what the error is
           guard let results = finishedRequest.results as? [VNClassificationObservation] else { return }
            guard let firstObservation = results.first else { return }
            print(firstObservation.identifier, firstObservation.confidence)
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
}

