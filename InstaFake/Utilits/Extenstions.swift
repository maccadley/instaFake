//
//  Extenstions.swift
//  InstaFake
//
//  Created by Admin on 27.08.2018.
//  Copyright © 2018 MaximMasov. All rights reserved.
//

import UIKit
import Firebase

extension UIColor{
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor{
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    static func mainBlue() -> UIColor {
        return UIColor.rgb(red: 17, green: 154, blue: 237)
    }
}


extension UIView{
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat){
        translatesAutoresizingMaskIntoConstraints = false
        if let top = top{
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        if let bottom = bottom{
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        if let right = right{
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        if width != 0{
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if height != 0{
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

extension Database {
    static func fetchUserWithUID(uid: String, completion: @escaping (User) -> ()){
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userDictionary = snapshot.value as? [String : Any] else {return}
            let user = User(uid: uid, dictionary: userDictionary)
            completion(user)
        }) { (error) in
            print("Failed to fetch user", error)
        }
    }
}

extension Date {
    func timeAgoDisplay() -> String{
        let secondsAgo = Int(Date().timeIntervalSince(self))
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        let year = 12 * month
        
        let quotient: Int
        let unit: String
        if secondsAgo < minute{
            quotient = secondsAgo
            unit = "second"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "minute"
        } else if secondsAgo < day{
            quotient = secondsAgo / hour
            unit = "hour"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "day"
        } else if secondsAgo < month{
            quotient = secondsAgo / week
            unit = "week"
        } else if secondsAgo < year{
            quotient = secondsAgo / month
            unit = "month"
        } else {
            quotient = secondsAgo / year
            unit = "year"
        }
        return "\(quotient) \(unit) \(quotient == 1 ? "" : "s") ago"
    }
}
