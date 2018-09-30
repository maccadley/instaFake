//
//  LoginController.swift
//  InstaFake
//
//  Created by Admin on 28.08.2018.
//  Copyright © 2018 MaximMasov. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController{
    
    let logoContrinerView: UIView = {
        let view = UIView()
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_white"))
        logoImageView.contentMode = .scaleAspectFill
        view.addSubview(logoImageView)
        logoImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.backgroundColor = UIColor.rgb(red: 0, green: 120, blue: 175)
        return view
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?  ", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor : UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Sign Up!", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.rgb(red: 17, green: 154, blue: 237)]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(logoContrinerView)
        logoContrinerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .white
        view.addSubview(signUpButton)
        signUpButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        setUpInputFileds()
    }
    //MARK: - Email and Password text fields
    
    fileprivate func setUpInputFileds(){
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, logInButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: logoContrinerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 140)
    }
    
    let emailTextField: UITextField = {
        let texfield = UITextField()
        texfield.placeholder = "Email"
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
    //MARK: - Log in button
    let logInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleLogIn), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    @objc func handleTextInputChange(){
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        if isFormValid{
            logInButton.isEnabled = true
            logInButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        } else {
            logInButton.isEnabled = false
            logInButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    
    @objc func handleLogIn(){
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error{
                print("problems with Signing in!",error)
                return
            }
            print("Successfuly", Auth.auth().currentUser?.uid ?? "")
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else {return}
            mainTabBarController.setupViewControllers()            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func handleSignUp(){
        let signUpController = SignUpController()
        
        navigationController?.pushViewController(signUpController, animated: true)
    }
    
    
}
