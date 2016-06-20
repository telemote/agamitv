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
        self.view.addSubview(Helper.getAppHeder(self.view, headerText: (Helper.tabs[4] as String).uppercaseString))
        
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
        descLabel.text = "AgamiTV is dedicated to produce and deliver high-quality video content to showcase the Bengali culture, literature and history. We are located in Austin, Texas. "
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        getConfigFromServer()
    }
    
    func getConfigFromServer(){
        
        let requestURL: NSURL = NSURL(string: Constants.CONFIG_FILE_PATH)!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL,
                                                                  cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData,
                                                                  timeoutInterval: 15.0)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            if(error != nil) {
                return;
            }
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
         
                do{
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    let liveevents = json["live"] as? [[String: AnyObject]]
                    let events = json["events"] as? [[String: AnyObject]]
                    
         
                    
                    //load tabs
                    if let entries = json["tabs"] as? [String] {
                        Helper.tabs.removeAll()
                        for entry in entries {
                            Helper.tabs.append(entry)
                        }
                    }
                    
         
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
         
                            
                            // update tabs
                            self.tabBarController!.tabBar.items?[0].title = Helper.tabs[0]
                            self.tabBarController!.tabBar.items?[1].title = Helper.tabs[1]
                            self.tabBarController!.tabBar.items?[2].title = Helper.tabs[2]
                            self.tabBarController!.tabBar.items?[3].title = Helper.tabs[3]
                            self.tabBarController!.tabBar.items?[4].title = Helper.tabs[4]
                            
                            //live feed count
                            if(liveevents?.count > 0) {
                                let x:Int = (liveevents?.count)!
                                self.tabBarController!.tabBar.items?[2].badgeValue = String(x)
                            }
                            if(events?.count > 0) {
                                let x:Int = (events?.count)!
                                self.tabBarController!.tabBar.items?[3].badgeValue = String(x)
                            }
                        })
         
                }catch {}
            }
        }
        task.resume()
    }
    

}
