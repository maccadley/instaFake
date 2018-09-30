//
//  Post.swift
//  InstaFake
//
//  Created by Admin on 01.09.2018.
//  Copyright © 2018 MaximMasov. All rights reserved.
//

import Foundation

struct Post{
    
    var id: String?
    let user: User
    let imageUrl: String
    let caption: String
    let creationDate: Date
    var hasLiked: Bool = true
    
    init(user: User, dictionaty: [String : Any]){
        self.imageUrl = dictionaty["imageUrl"] as? String ?? ""
        self.user = user
        //self.caption = dictionaty["caption"] as? String ?? ""
        self.caption = dictionaty["capturedText"] as? String ?? ""
        let secondsFrom1970 = dictionaty["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
