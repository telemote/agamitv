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
        self.view.addSubview(Helper.getAppHeder(self.view, headerText: "ABOUT"))
        
        // add logo
        let logo = UIImageView(frame: CGRect(x: self.view.frame.size.width/2-100, y: 70, width: 200, height: 200))
        logo.contentMode = UIViewContentMode.ScaleAspectFit
        logo.layer.cornerRadius = 8
        logo.clipsToBounds = true
        logo.image = UIImage(named: "aboutlogo.png")
        self.view.addSubview(logo)
        
        // Add description
        let descLabel = UILabel(frame: CGRect(x: 10, y: 275 , width: self.view.frame.size.width-20, height: 120))
        descLabel.numberOfLines = 0
        descLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        descLabel.textAlignment = .Center
        descLabel.text = "AgamiTV is dedicated to create and deliver high quality video content to show case the Bengali culture and history. We are located in Austin, Texas."
        self.view.addSubview(descLabel)
        
        //weblink
        let link = UIButton(frame: CGRect(x: self.view.frame.size.width/2-100, y: 400 , width: 200, height: 30))
        link.setTitle("www.agamitv.com", forState: .Normal)
        link.setTitleColor(UIColor.blueColor(), forState: .Normal)
        link.addTarget(self, action: #selector(self.pressed(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(link)
    }
    
    
    
    func pressed(sender: UIButton!) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.agamitv.com")!)
    }

}
