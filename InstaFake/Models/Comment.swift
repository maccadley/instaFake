//
//  Comment.swift
//  InstaFake
//
//  Created by Admin on 15.09.2018.
//  Copyright © 2018 MaximMasov. All rights reserved.
//

import Foundation

struct Comment {
    
    let user: User
    let text: String
    let uid: String
    
    init(user: User, dictionary: [String: Any]) {
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.user = user
    }
}
