//
//  ViewController.swift
//  MLCamera
//
//  Created by Michael Inger on 12/06/2017.
//  Copyright © 2017 stringCode ltd. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import CoreML

/// MLCameraViewController sets up AVCaptureSession & presents AVCaptureVideoPreviewLayer.
/// Uses AVCaptureOutput's pixel buffer to create classification request to Inceptionv3
/// model. Device rotation handled by setting orientation on AVCaptureConnection (not ideal).
/// See: deviceOrientationDidChange(_:) comment.
class MLCameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

	@IBOutlet weak var stackView: UIStackView!
	@IBOutlet weak var loadingLabel: UILabel!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	/// Displays video preview via AVCaptureVideoPreviewLayer
    @IBOutlet weak var cameraPreview: CameraPreviewView!
    /// Embeded view controller that displays classifications result
    weak var clasificationResultsVC: ClassificationResultsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Observe device orientation notifications to adjust AVCaptureConnection
        let selector = #selector(deviceOrientationDidChange(_:))
        UIDevice.subscribeToDeviceOrientationNotifications(self, selector:selector)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Request permisions to AVCaptureDevice
        AVCaptureDevice.requestAuthorization { [weak self] (granted) in
            self?.permissions(granted)
        }
        session?.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        session?.stopRunning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get reference to embeded view controller
        if let vc = segue.destination as? ClassificationResultsViewController {
            clasificationResultsVC = vc
        }
    }
    
    // MARK: AVCaptureSession setup
    
    private var session: AVCaptureSession?
    
    /// Sets up AVCapture session if possible & needed
    private func permissions(_ granted: Bool) {
        if granted && self.session == nil {
            self.setupSession()
        }
    }
    
    private func setupSession() {
        guard let device = AVCaptureDevice.default(for: .video) else {
            fatalError("Capture device not available")
        }
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            fatalError("Capture input not available")
        }
        let output = AVCaptureVideoDataOutput()
        let session = AVCaptureSession()
        session.addInput(input)
        session.addOutput(output)
        output.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .userInteractive))
        // Setup preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        cameraPreview.addCaptureVideoPreviewLayer(previewLayer)
        self.session = session
        session.startRunning()
    }
    
    /// Update orientation for AVCaptureConnection so that CVImageBuffer pixels
    /// are rotated correctly in captureOutput(_:didOutput:from:)
    /// - Note: Even though rotation of pixel buffer is hardware accelerated,
    /// this is not the most effecient way of handling it. I was not able to test
    /// getting exif rotation based on device rotation, hence rotating the buffer
    /// I will update it in a near future
    @objc private func deviceOrientationDidChange(_ notification: Notification) {
        session?.outputs.forEach {
            $0.connections.forEach {
                $0.videoOrientation  = orientation(videoOrientation: $0.videoOrientation, deviceOrientation: UIDevice.current.orientation)
            }
        }
    }
    
    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Note: Pixel buffer is already correctly rotated based on device rotation
        // See: deviceOrientationDidChange(_:) comment
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        var requestOptions: [VNImageOption: Any] = [:]
        if let cameraIntrinsicData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            requestOptions = [.cameraIntrinsics: cameraIntrinsicData]
        }
        // Run the Core ML classifier - results in handleClassification method
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: requestOptions)
        do {
            try handler.perform([classificationRequest])
        } catch {
            print(error)
        }
    }
    
    // MARK: ML
    
    lazy var classificationRequest: VNCoreMLRequest = {
        // Load the ML model through its generated class and create a Vision request for it.
        do {
			DispatchQueue.main.async {
				self.activityIndicator.startAnimating()
			}
            let model = try VNCoreMLModel(for: Inceptionv3().model)
            let request = VNCoreMLRequest(model: model, completionHandler: self.handleClassification)
            request.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
			DispatchQueue.main.async {
				self.activityIndicator.stopAnimating()
				self.stackView.removeFromSuperview()
			}
            return request
        } catch {
            fatalError("can't load Vision ML model: \(error)")
        }
    }()
    
    func handleClassification(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNClassificationObservation] else {
            fatalError("unexpected result type from VNCoreMLRequest")
        }
        // Filter observation
        let filteredOservations = observations[0...10].filter({ $0.confidence > 0.1 })
        // Update UI
        DispatchQueue.main.async { [weak self] in
            self?.clasificationResultsVC?.observations = filteredOservations
        }
    }
}
