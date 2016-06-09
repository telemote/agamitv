//
//  AboutVC.swift
//  AgamiTV
//
//  Created by Arif Saikat on 6/8/16.
//  Copyright © 2016 Agavi TV. All rights reserved.
//

import UIKit

class AboutVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // add app wide header
        var v = UIView()
        v.backgroundColor = Constants.RED
        v.frame = CGRectMake(0, 0, self.view.bounds.width, 64)
        
        let textFrame = CGRect(x: self.view.bounds.width/2-49, y: 28 , width: 100, height: 30)
        var textLabel = UILabel(frame: textFrame)
        //textLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        textLabel.textAlignment = .Center
        textLabel.font = UIFont.boldSystemFontOfSize(17.0)
        textLabel.attributedText = NSMutableAttributedString(
            string: "AgamiTV",
            attributes:[ NSForegroundColorAttributeName: UIColor.whiteColor()])
        v.addSubview(textLabel)
        self.view.addSubview(v)
        
        // add logo
        var logo = UIImageView(frame: CGRect(x: self.view.frame.size.width/2-100, y: 70, width: 200, height: 200))
        logo.contentMode = UIViewContentMode.ScaleAspectFit
        logo.layer.cornerRadius = 8
        logo.image = UIImage(named: "splash.png")
        self.view.addSubview(logo)
        
        // Add description
        var descLabel = UILabel(frame: CGRect(x: 10, y: 275 , width: self.view.frame.size.width-20, height: 90))
        //textLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        descLabel.numberOfLines = 0
        descLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        //textLabel.font = textLabel.font.fontWithSize(16)
        descLabel.textAlignment = .Center
        descLabel.text = "AgamiTV is dedicated to create and deliver high quality video content to show case the Bengali culture and history. We are located in Austin, Texas."
         self.view.addSubview(descLabel)
        
        //weblink
        var link = UIButton(frame: CGRect(x: self.view.frame.size.width/2-100, y: 370 , width: 200, height: 30))
        link.setTitle("www.agamitv.com", forState: .Normal)
        link.setTitleColor(UIColor.blueColor(), forState: .Normal)
        link.addTarget(self, action: #selector(self.pressed(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(link)

    }
    
    func pressed(sender: UIButton!) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.agamitv.com")!)
    }

}
