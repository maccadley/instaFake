//
//  UserProfileHeader.swift
//  InstaFake
//
//  Created by Admin on 28.08.2018.
//  Copyright © 2018 MaximMasov. All rights reserved.
//

import UIKit
import Firebase

protocol UserProfileHeaderDelegate {
    func didChangedToListView()
    func didChangedToGridView()
}

class UserProfileHeader: UICollectionViewCell{
    
    var delegate: UserProfileHeaderDelegate?
    
    var user: User? {
        didSet{
            guard let profileImageUrl = user?.profileImageUrl else {return}
            profileImageView.loadImage(urlString: profileImageUrl)
            usernameLabel.text = user?.username
            
            setupEditFollowButton()
      
        }
    }
    
    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        return imageView
    }()
    //MARK: -BUTTONS OUTLETS
    lazy var gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        button.addTarget(self, action: #selector(handleChangeGridView), for: .touchUpInside)
        return button
    }()
    
    lazy var listButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        button.addTarget(self, action: #selector(handleToListView), for: .touchUpInside)
        return button
    }()
    
    let bookMarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    //MARK: - Stats Labels
    let postLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "11\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedStringKey.foregroundColor:UIColor.lightGray, NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let followersLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "follows", attributes: [NSAttributedStringKey.foregroundColor:UIColor.lightGray, NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let followingLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedStringKey.foregroundColor:UIColor.lightGray, NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        profileImageView.clipsToBounds = true
        
        setupButtomToolBar()
        addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: gridButton.topAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        
        setupUserStatsView()
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: postLabel.bottomAnchor, left: postLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 34)
    }
    
    fileprivate func setupUserStatsView(){
        let stackView = UIStackView(arrangedSubviews: [postLabel, followersLabel, followingLabel])
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 50)
    }
    
    fileprivate func setupButtomToolBar(){
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor.lightGray
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor.lightGray
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookMarkButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        stackView.anchor(top: nil, left: leftAnchor, bottom: self.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.3)
        bottomDividerView.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.3)
    }
    
    //Checking wheather user on personal page, or visiting someone else
    //If is on someone's page then changing button on "Follow"
    fileprivate func setupEditFollowButton(){
        guard let currentLoggedUserId = Auth.auth().currentUser?.uid else {return}
        guard let userId = user?.uid else {return}
        if currentLoggedUserId == userId{
            //Edit profile
        } else {
            //Check if following
    Database.database().reference().child("following").child(currentLoggedUserId).child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                if let isFollowing = snapshot.value as? Int, isFollowing == 1{
                    self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                } else {
                    self.setupFollowStyle()
                }
            }) { (error) in
                print("Failed to check if following", error)
            }
        }
    }
    
    @objc func handleEditProfileOrFollow(){
        guard let currentLoggedInId = Auth.auth().currentUser?.uid else {return}
        guard let userId = user?.uid else {return}
        if editProfileFollowButton.titleLabel?.text == "Unfollow"{
            //Get into branch with currentLoggedUser and userId and there we delete this value (userId)
           //Unfollow the user and set button's collor and title to default "follow"
            Database.database().reference().child("following").child(currentLoggedInId).child(userId).removeValue { (error, reference) in
                if let error = error {
                    print("failed to unfollow user", error)
                    return
                }
                self.setupFollowStyle()
            }
        } else{
            let reference = Database.database().reference().child("following").child(currentLoggedInId)
            let values = [userId: 1]
            reference.updateChildValues(values) { (error, references) in
                if let error = error {
                    print("Failed to follow user", error)
                    return
                }
                self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                self.editProfileFollowButton.backgroundColor = .white
                self.editProfileFollowButton.setTitleColor(.black, for: .normal)
            }
        }
    }
    
    @objc func handleToListView(){
        listButton.tintColor = .mainBlue()
        gridButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangedToListView()
    }
    
    @objc func handleChangeGridView(){
        gridButton.tintColor = .mainBlue()
        listButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangedToGridView()
    }
    
    fileprivate func setupFollowStyle(){
        self.editProfileFollowButton.setTitle("Follow", for: .normal)
        self.editProfileFollowButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        self.editProfileFollowButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        self.editProfileFollowButton.setTitleColor(.white, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
