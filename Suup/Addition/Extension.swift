//
//  Extension.swift
//  Suup
//
//  Created by Gauri Bhagwat on 14/06/18.
//  Copyright © 2018 Development. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImageFromCache(urlString: String){
        self.image = nil
        //Cetch Cached Image
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject){
            self.image = (cachedImage as! UIImage)
            return
        }
        
        
        let url = NSURL(string: urlString)
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) in
            if error != nil {
                print(error)
                return
            }
            DispatchQueue.main.async {
                
                if let downloadImage = UIImage(data: data!){
                    imageCache.setObject(downloadImage, forKey: urlString as AnyObject)
                    self.image = downloadImage
                }
               

            }
            
            }.resume()
    }
    }

