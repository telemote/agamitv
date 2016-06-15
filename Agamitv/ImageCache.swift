//
//  ImageCache.swift
//  AgamiTV
//
//  Created by Arif Saikat on 6/2/16.
//  Copyright © 2016 Agavi TV. All rights reserved.
//

import Foundation

import UIKit
import WebKit
import AVKit
import AVFoundation

class MyImageCache {
    
    static let sharedCache: NSCache = {
        let cache = NSCache()
        cache.name = "MyImageCache"
        cache.countLimit = 200 // Max 200 images in memory.
        cache.totalCostLimit = 100*1024*1024 // Max 100MB used.
        return cache
    }()
}

extension UIImage {
    
    func addShadow(blurSize: CGFloat = 6.0) -> UIImage {
        
        let data : UnsafeMutablePointer<Void> = nil
        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()!
        let bitmapInfo : CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        
        let myColorValues:[CGFloat] = [0.0, 0.0, 0.0, 0.8]
        let myColor = CGColorCreate(colorSpace, myColorValues)
        
        let shadowContext : CGContextRef = CGBitmapContextCreate(data, Int(self.size.width + blurSize), Int(self.size.height + blurSize), CGImageGetBitsPerComponent(self.CGImage), 0, colorSpace, bitmapInfo.rawValue)!
        
        CGContextSetShadowWithColor(shadowContext, CGSize(width: blurSize/2,height: -blurSize/2),  blurSize, myColor)
        CGContextDrawImage(shadowContext, CGRect(x: 0, y: blurSize, width: self.size.width, height: self.size.height), self.CGImage)
        
        let shadowedCGImage : CGImageRef = CGBitmapContextCreateImage(shadowContext)!
        let shadowedImage : UIImage = UIImage(CGImage: shadowedCGImage)
        
        return shadowedImage
    }
}

extension NSURL {
    
    typealias ImageCacheCompletion = UIImage -> Void
    
    /// Retrieves a pre-cached image, or nil if it isn't cached.
    /// You should call this before calling fetchImage.
    var cachedImage: UIImage? {
        return MyImageCache.sharedCache.objectForKey(
            absoluteString) as? UIImage
    }
    
    /// Fetches the image from the network.
    /// Stores it in the cache if successful.
    /// Only calls completion on successful image download.
    /// Completion is called on the main thread.
    func fetchImage(completion: ImageCacheCompletion) {
        let task = NSURLSession.sharedSession().dataTaskWithURL(self) {
            data, response, error in
            if error == nil {
                if let  data = data,
                    image = UIImage(data: data) {
                    MyImageCache.sharedCache.setObject(
                        image,
                        forKey: self.absoluteString,
                        cost: data.length)
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(image)
                    }
                }
            }
        }
        task.resume()
    }
    
}
