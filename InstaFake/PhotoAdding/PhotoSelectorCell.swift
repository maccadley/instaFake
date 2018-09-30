//
//  PhotoSelectorCell.swift
//  InstaFake
//
//  Created by Admin on 29.08.2018.
//  Copyright © 2018 MaximMasov. All rights reserved.
//

import UIKit

class PhotoSelectorCell: UICollectionViewCell{
    
    let photoImageView: UIImageView = {
        let imaveView = UIImageView()
        imaveView.contentMode = .scaleAspectFill
        imaveView.clipsToBounds = true
        imaveView.backgroundColor = .lightGray
        return imaveView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

