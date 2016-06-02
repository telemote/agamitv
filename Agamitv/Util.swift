//
//  Util.swift
//  Agamitv
//
//  Created by Arif Saikat on 5/30/16.
//  Copyright © 2016 Agavi TV. All rights reserved.
//

import Foundation

struct Constants {
    static let SERVER = "http://ww2.agamitv.com"
    static let IMAGE_BASE_PATH = SERVER + "/ios/image/"
    static let VIDEO_BASE_PATH = SERVER + "/ios/video/"
    static let CONFIG_FILE_PATH = SERVER + "/ios/config/ios.json"
}

class Helper {
   static func drawPlayButtonWaterMark(inImage backgroundImage:UIImage) -> UIImage{
        let foreGroundImage = UIImage(named: "play.png")
        let point = CGPoint(x: (backgroundImage.size.width)/2-(foreGroundImage?.size.width)!/2,
                            y: (backgroundImage.size.height)/2-(foreGroundImage?.size.height)!/2)
        UIGraphicsBeginImageContextWithOptions(backgroundImage.size, false, 0.0)
        backgroundImage.drawInRect(CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height))
        foreGroundImage! .drawInRect(CGRectMake(point.x, point.y, foreGroundImage!.size.width, foreGroundImage!.size.height), blendMode: CGBlendMode.Normal, alpha: 0.8)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

