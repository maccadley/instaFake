//
//  CameraController.swift
//  InstaFake
//
//  Created by Admin on 05.09.2018.
//  Copyright © 2018 MaximMasov. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController: UIViewController, AVCapturePhotoCaptureDelegate, UIViewControllerTransitioningDelegate{
    
    let output = AVCapturePhotoOutput()
    // Buttons
    let dismissButton: UIButton = {
       let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "right_arrow_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    let capturePhotoButton: UIButton = {
       let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "capture_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCapturePhoto), for: .touchUpInside)
        return button
    }()
    
    let customAnimationPresentor = CustomAnimationPresentor()
    let customAnimationDismisser = CustomAnimationDismisser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transitioningDelegate = self
        setupCameraCaptureSession()
        setupHUD()
        
    }
    
    //For animated transition
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationPresentor
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return customAnimationDismisser
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    //Methods
    fileprivate func setupHUD(){
    view.addSubview(capturePhotoButton)
    capturePhotoButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 15, paddingRight: 0, width: 80, height: 80)
    capturePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    view.addSubview(dismissButton)
    dismissButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 50)
    }
    
    //MARK: - Method for camera session
    fileprivate func setupCameraCaptureSession(){
        //Inputs
        let captureSession = AVCaptureSession()
        let captureDevice = AVCaptureDevice.default(for: .video)
        do{
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            if captureSession.canAddInput(input){
                 captureSession.addInput(input)
            }
        } catch let error{
            print("Couldn't activate the camera", error)
        }
       // Outputs
        
        if captureSession.canAddOutput(output){
            captureSession.addOutput(output)
        }
       
        // Setup output preview
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        captureSession.startRunning()
        
    }
    
    //Capture a photo
    
    @objc func handleCapturePhoto(){
        let setting = AVCapturePhotoSettings()
        //take the first availible type
        guard let priveiwFormatType = setting.availableEmbeddedThumbnailPhotoCodecTypes.first else {return}
        setting.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey : priveiwFormatType] as [String : Any]
        output.capturePhoto(with: setting, delegate: self)
    }
    
    //Making captured image as a view
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else {return}
        let previewImage = UIImage(data: imageData)
        let containerView = PreviewPhotoContainerView()
        containerView.previewImageView.image = previewImage
        view.addSubview(containerView)
        containerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    
    @objc func handleDismiss(){
        dismiss(animated: true, completion: nil)
    }
    
    
    
}
