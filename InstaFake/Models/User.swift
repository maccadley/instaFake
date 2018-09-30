//
//  User.swift
//  InstaFake
//
//  Created by Admin on 01.09.2018.
//  Copyright © 2018 MaximMasov. All rights reserved.
//

import Foundation

struct User {
    
    let uid:String
    let username: String
    let profileImageUrl: String
    
    init(uid: String, dictionary: [String:Any]){
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.uid = uid
    }
}
