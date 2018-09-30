//
//  SharePhotoController.swift
//  InstaFake
//
//  Created by Admin on 01.09.2018.
//  Copyright © 2018 MaximMasov. All rights reserved.
//

import UIKit
import Firebase

class SharePhotoController: UIViewController{
    
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "UpdateFeed")
    
    var selectedImage: UIImage?{
        didSet{
            self.imageView.image = selectedImage
        }
    }
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .red
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let textView: UITextView = {
        let text = UITextView()
        text.font = UIFont.systemFont(ofSize: 14)
        return text
    }()
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        setupImageAndTextViews()
    }

    override var prefersStatusBarHidden: Bool{
        return true
    }

    @objc func handleShare(){
        guard let caturedText = textView.text else {return}
        guard caturedText.count > 0 else {return}
        guard let image = selectedImage else {return}
        guard let uploadData = UIImageJPEGRepresentation(image, 0.5) else {return}
        navigationItem.rightBarButtonItem?.isEnabled = false
        let filename = NSUUID().uuidString
        Storage.storage().reference().child("posts").child(filename).putData(uploadData, metadata: nil) { (metaData, error) in
            if let error = error {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed with uploading",error)
                return
            }
            print("Success", metaData ?? "")
            Storage.storage().reference().child("posts").child(filename).downloadURL(completion: { (url, error) in
                if let error = error{
                    print("Some problem with downloading URL:", error)
                }
                guard let pictureURL = url?.absoluteString else {return}
                self.saveToDatabaseWithImageUrl(imageUrl: pictureURL)
            })
        }
    }
    
    fileprivate func saveToDatabaseWithImageUrl(imageUrl: String){
        guard let postImage = selectedImage else {return}
        guard let cationText = textView.text else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let userPostRef = Database.database().reference().child("posts").child(uid)
        let reference = userPostRef.childByAutoId()
        let values = ["imageUrl" : imageUrl, "capturedText" : cationText, "imageWidth" : postImage.size.width, "imageHeight" : postImage.size.height, "CreationDate" : Date().timeIntervalSince1970] as [String : Any]
        reference.updateChildValues(values) { (error, reference) in
            if let error = error {
                print("Problems with saving", error)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
            print("Successfuly saved to DB", reference)
            self.dismiss(animated: true, completion: nil)
            
            NotificationCenter.default.post(name: SharePhotoController.updateFeedNotificationName, object: nil)
        }
    }
    
    fileprivate func setupImageAndTextViews(){
        let containverView = UIView()
        containverView.backgroundColor = .white
        view.addSubview(containverView)
        containverView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        
        containverView.addSubview(imageView)
        imageView.anchor(top: containverView.topAnchor, left: containverView.leftAnchor, bottom: containverView.bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 84, height: 0)
        
        containverView.addSubview(textView)
        textView.anchor(top: containverView.topAnchor, left: imageView.rightAnchor, bottom: containverView.bottomAnchor, right: containverView.rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    
   
    
    
    
    
}
