//
//  Util.swift
//  Agamitv
//
//  Created by Arif Saikat on 5/30/16.
//  Copyright © 2016 Agavi TV. All rights reserved.
//

import Foundation

import UIKit
import WebKit
import AVKit
import AVFoundation

struct Constants {
    static let SERVER = "http://ww2.agamitv.com"
    static let IMAGE_BASE_PATH = SERVER + "/ios/image/"
    static let VIDEO_BASE_PATH = SERVER + "/ios/video/"
    static let CONFIG_FILE_PATH = SERVER + "/ios/config/ios.json"
    static let GREEN = UIColor(red:14, green: 86, blue: 43)
    static let RED = UIColor(red:227, green: 0, blue: 28)
}

class Helper {
   static func drawPlayButtonWaterMark(inImage backgroundImage:UIImage) -> UIImage{
        let foreGroundImage = UIImage(named: "play.png")
        let point = CGPoint(x: (backgroundImage.size.width)/2-(foreGroundImage?.size.width)!/2,
                            y: (backgroundImage.size.height)/2-(foreGroundImage?.size.height)!/2)
        UIGraphicsBeginImageContextWithOptions(backgroundImage.size, false, 0.0)
        backgroundImage.drawInRect(CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height))
        foreGroundImage! .drawInRect(CGRectMake(point.x, point.y, foreGroundImage!.size.width, foreGroundImage!.size.height), blendMode: CGBlendMode.Normal, alpha: 0.6)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}



extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}


