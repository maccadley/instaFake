//
//  CommentCell.swift
//  InstaFake
//
//  Created by Admin on 15.09.2018.
//  Copyright © 2018 MaximMasov. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell{
    
    var comment: Comment? {
        didSet {
            guard let comment = comment else {return}
            let attributedText = NSMutableAttributedString(string: comment.user.username, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: " " + comment.text, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
            
            textView.attributedText = attributedText
            textView.text = comment.text
            profileImageView.loadImage(urlString: comment.user.profileImageUrl)
        }
    }
    
    let textView: UITextView = {
        let label = UITextView()
        label.font = UIFont.systemFont(ofSize: 14)
     //   label.numberOfLines = 0
      //  label.backgroundColor = .lightGray
        label.isScrollEnabled = false
        return label
    }()
    
    let profileImageView: CustomImageView = {
       let imageView = CustomImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .blue
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        addSubview(textView)
        textView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
