//
//  ViewController.swift
//  InstaFake
//
//  Created by Admin on 27.08.2018.
//  Copyright © 2018 MaximMasov. All rights reserved.
//

import UIKit
import Firebase

class SignUpController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // Manualy adding button and textField, and adding some proporities
    //MARK: - Add Photo button
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        return button
    }()
    //MARL: - Text fields
    let emailTextField: UITextField = {
        let texfield = UITextField()
        texfield.placeholder = "Email"
        texfield.backgroundColor = UIColor(white: 0, alpha: 0.03)
        texfield.borderStyle = .roundedRect
        texfield.font = UIFont.systemFont(ofSize: 14)
        texfield.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return texfield
    }()
    
    let usernameTextField: UITextField = {
        let texfield = UITextField()
        texfield.placeholder = "Username"
        texfield.backgroundColor = UIColor(white: 0, alpha: 0.03)
        texfield.borderStyle = .roundedRect
        texfield.font = UIFont.systemFont(ofSize: 14)
        texfield.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return texfield
    }()
    
   
    
    let passwordTextField: UITextField = {
        let texfield = UITextField()
        texfield.placeholder = "Password"
        texfield.isSecureTextEntry = true
        texfield.backgroundColor = UIColor(white: 0, alpha: 0.03)
        texfield.borderStyle = .roundedRect
        texfield.font = UIFont.systemFont(ofSize: 14)
        texfield.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return texfield
    }()
    
    let signUpButton: UIButton = {
       let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor : UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Log in!", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.rgb(red: 17, green: 154, blue: 237)]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleAlreadyhaveAccount), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Methods
    //Check if there is some text in text fields and change color of button
    @objc func handleTextInputChange(){
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && usernameTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        if isFormValid{
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = .mainBlue()
        } else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    //MARK: - Creating mew user
    // On pressing button we create a new user, checking if there are all of text fields are filled
    @objc func handleSignUp(){
        guard let email = emailTextField.text, emailTextField.text != nil else {return}
        guard let username = usernameTextField.text, usernameTextField.text != nil else {return}
        guard let password = passwordTextField.text, passwordTextField.text != nil else {return}
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let err = error{
                print("Failed to create user", err)
                return
            }
            print("Successful! User:", Auth.auth().currentUser?.uid ?? "")
            
            guard let image = self.plusPhotoButton.imageView?.image else {return}
            guard let uploadData = UIImageJPEGRepresentation(image, 0.5) else {return}
            let fileName = NSUUID().uuidString
            
            let storageRef = Storage.storage().reference()
            let storageRefChild = storageRef.child("profile_images").child(fileName)
            
            storageRefChild.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if let error = error{
                    print("Unable to upload image to storage due to:", error)
                    return
            }
                //The idea is to create new user inside closure with downloadURL constant
                storageRefChild.downloadURL(completion: { (url, error) in
                    if let error = error{
                        print("Unable to retrieve URL due to error:", error)
                        return
                    }
                    let profilePicUrl = url?.absoluteString
                    print("Profile was sucessfuly uploaded! The url is:", profilePicUrl ?? "")

                    guard let uid = Auth.auth().currentUser?.uid else {return}
                    let userNameValues = ["username": username, "profileImageUrl": profilePicUrl]
                    let values = [uid: userNameValues]
                    Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
                        if let err = err{
                            print("Failed to save user info:\(err)")
                            return
                        }
                        guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else {return}
                        mainTabBarController.setupViewControllers()
                        self.dismiss(animated: true, completion: nil)
                    })
                })
            })
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(loginButton)
        loginButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        //To show button and textfield, we must add them on viewDidLoad with addSubview
        //And adding them contraints. They must be enabled also
        view.addSubview(plusPhotoButton)
        plusPhotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        setupInputFiles()

    }

    //Setup StackView
    fileprivate func setupInputFiles(){
        //This constant contrains all the textField That we created manualy
        let stackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField, signUpButton])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        view.addSubview(stackView)
        
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 200)
    }
    //MARK: -Picker controller
    @objc func handlePlusPhoto(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originaImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            plusPhotoButton.setImage(originaImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width/2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 3
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleAlreadyhaveAccount(){
       _ = navigationController?.popViewController(animated: true)
    }
    
}

