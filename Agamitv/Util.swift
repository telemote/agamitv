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
    static let CONFIG_FILE_PATH = "http://ww2.agamitv.com/ios/config/ios.json"
    static let GREEN = UIColor(red:14, green: 86, blue: 43)
    static let RED = UIColor(red:227, green: 0, blue: 28)
    static let WHITE = UIColor.whiteColor()
}

class Helper {
    
    static var tabs: [String] = ["Recent", "Shows", "Videos", "Upcoming", "About"]
    
    static func createUnselectedVideoImage(drawText: NSString, inImage: UIImage) -> UIImage {
        return textToImage(drawText, inImage: drawPlayButtonWaterMark(inImage: inImage, playImage: UIImage(named: "whiteplay.png")!), atPoint: CGPointMake(10, inImage.size.height*3/4), textColor: UIColor.whiteColor())
    }
    
    static func createSelectedVideoImage(drawText: NSString, inImage: UIImage) -> UIImage {
        return textToImage(drawText, inImage: drawPlayButtonWaterMark(inImage: inImage, playImage: UIImage(named: "redplay.png")!), atPoint: CGPointMake(10, inImage.size.height*3/4), textColor: UIColor.redColor())
    }
    
    static func createNoPlayVideoImage(drawText: NSString, inImage: UIImage) -> UIImage {
        return textToImage(drawText, inImage: Helper.imageWithGradient(inImage), atPoint: CGPointMake(10, inImage.size.height*3/4), textColor: UIColor.whiteColor())
    }

    
    static func imageWithGradient(img:UIImage!) -> UIImage{
        UIGraphicsBeginImageContext(img.size)
        let context = UIGraphicsGetCurrentContext()
        img.drawAtPoint(CGPointMake(0, 0))
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations:[CGFloat] = [0.50, 1.0]
        //1 = opaque
        //0 = transparent
        let bottom = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).CGColor
        let top = UIColor(red: 0, green: 0, blue: 0, alpha: 0).CGColor
        
        let gradient = CGGradientCreateWithColors(colorSpace, [top, bottom], locations)
        let startPoint = CGPointMake(img.size.width/2, 0)
        let endPoint = CGPointMake(img.size.width/2, img.size.height)
        
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    static func drawPlayButtonWaterMark(inImage backgroundImage:UIImage, playImage foreGroundImage:UIImage) -> UIImage{
        //let foreGroundImage = UIImage(named: "playf.png")
        let point = CGPoint(x: (backgroundImage.size.width)/2-(foreGroundImage.size.width)/2,
                            y: (backgroundImage.size.height)/2-(foreGroundImage.size.height)/2)
        UIGraphicsBeginImageContextWithOptions(backgroundImage.size, false, 0.0)
        backgroundImage.drawInRect(CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height))
        foreGroundImage .drawInRect(CGRectMake(point.x, point.y, foreGroundImage.size.width, foreGroundImage.size.height), blendMode: CGBlendMode.Normal, alpha: 1.0)
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Helper.imageWithGradient(newImage)
    }
    
    
    
    static func textToImage(drawText: NSString, inImage: UIImage, atPoint:CGPoint, textColor:UIColor)->UIImage{
        
        
        // Setup the font specific variables
        //var textColor: UIColor = UIColor.whiteColor()
        var textFont: UIFont = UIFont(name: "AvenirNext-Bold", size: 18.0)!
        
        //Setup the image context using the passed image.
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(inImage.size, false, scale)
        
        //Setups up the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            ]
        
        //Put the image into a rectangle as large as the original image.
        inImage.drawInRect(CGRectMake(0, 0, inImage.size.width, inImage.size.height))
        
        // Creating a point within the space that is as bit as the image.
        var rect: CGRect = CGRectMake(atPoint.x, atPoint.y, inImage.size.width-20, inImage.size.height)
        
        //Now Draw the text into an image.
        drawText.drawInRect(rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        var newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //And pass it back up to the caller.
        return newImage
        
    }
    
    static func getAppHeder(rootView:UIView, headerText:String)-> UIView{
        
        let app = UIApplication.sharedApplication()
        let headerView = UIView(frame: CGRectMake(0, app.statusBarFrame.size.height, rootView.bounds.width, 36))
        
        
        let logoView = UIView(frame: CGRectMake(0, 0, rootView.bounds.width, 18))
        let logo1 = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 16))
        logo1.contentMode = UIViewContentMode.ScaleAspectFit
        logo1.layer.cornerRadius = 8
        logo1.clipsToBounds = true
        logo1.center = CGPointMake(logoView.frame.size.width/2, 10)
        logo1.image = UIImage(named: "headerlogo.png")
        logoView.addSubview(logo1)
        headerView.addSubview(logoView)
        
        // let banner = UIView(frame: CGRectMake(0, app.statusBarFrame.size.height+, self.view.bounds.width, 22))
        
        let bannerView = UIView(frame: CGRectMake(0, 18, rootView.bounds.width, 18))
        bannerView.backgroundColor = Constants.GREEN
        let textLabel = UILabel(frame: CGRect(x: bannerView.frame.size.width/2, y: 0 , width: 200, height: 18))
        textLabel.textAlignment = .Center
        textLabel.center = CGPointMake(bannerView.frame.size.width/2, 9)
        textLabel.font = UIFont.boldSystemFontOfSize(14.0)
        textLabel.attributedText = NSMutableAttributedString(
            string: headerText,
            attributes:[ NSForegroundColorAttributeName: UIColor.whiteColor()])
        bannerView.addSubview(textLabel)
        headerView.addSubview(bannerView)
        
        headerView.backgroundColor = Constants.WHITE
        return headerView
        
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


