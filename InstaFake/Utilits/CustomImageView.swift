//
//  CustomImageView.swift
//  InstaFake
//
//  Created by Admin on 01.09.2018.
//  Copyright © 2018 MaximMasov. All rights reserved.
//

import UIKit

var imageCache = [String : UIImage]()

class CustomImageView: UIImageView{
    
    var lastUrlUsedToLoadImage: String?
    
    func loadImage(urlString: String){
        lastUrlUsedToLoadImage = urlString
        self.image = nil
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        guard let url = URL(string: urlString) else {return}
        URLSession.shared.dataTask(with: url) { (data, responce, error) in
            if let error = error {
                print("Failed to fetch post image", error)
                return
            }
            if url.absoluteString != self.lastUrlUsedToLoadImage{
                return
            }
            
            guard let imageData = data else {return}
            let photoImage = UIImage(data: imageData)
            imageCache[url.absoluteString] = photoImage
            DispatchQueue.main.async {
                self.image = photoImage
            }
            }.resume()
    }
}
