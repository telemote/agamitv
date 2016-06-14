//
//  TabBarController.swift
//  AgamiTV
//
//  Created by Arif Saikat on 5/31/16.
//  Copyright © 2016 Agavi TV. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().tintColor = UIColor.whiteColor()
        
        // Sets the default color of the background of the UITabBar
        UITabBar.appearance().barTintColor = Constants.GREEN
        
        // Sets the background color of the selected UITabBarItem (using and plain colored UIImage with the width = 1/5 of the tabBar (if you have 5 items) and the height of the tabBar)
       // UITabBar.appearance().selectionIndicatorImage = UIImage().makeImageWithColorAndSize(UIColor.blueColor(), size: CGSizeMake(tabBar.frame.width/5, tabBar.frame.height))
        
        // Uses the original colors for your images, so they aren't not rendered as grey automatically.
       // for item in self.tabBar.items as! [UITabBarItem] {
        //    if let image = item.image {
         //       item.image = image.imageWithRenderingMode(.AlwaysOriginal)
          //  }
       // }
        self.selectedIndex = 0
        getConfigFromServer()
    }
     var tabs: [String] = []
    
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
                    
                    if let entries = json["tabs"] as? [String] {
                        
                        var i:Int = 0
                        
                        
                        for entry in entries {
                            self.tabs.append(entry)
                           
                            i =  i+1
                            
                            
                    }
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                           
                                self.tabBar.items?[0].title = self.tabs[0]
                             self.tabBar.items?[1].title = self.tabs[1]
                             self.tabBar.items?[2].title = self.tabs[2]
                            self.tabBar.items?[3].title = self.tabs[3]
                            self.tabBar.items?[4].title = self.tabs[4]
                            //live feed count
                            
                            
                            if(liveevents?.count > 0) {
                                let x:Int = (liveevents?.count)!
                                self.tabBar.items?[1].badgeValue = String(x)
                            }
                            if(events?.count > 0) {
                                let x:Int = (events?.count)!
                                self.tabBar.items?[3].badgeValue = String(x)
                            }
                            
                        })
                        
                    }
                }catch {}
            }
        }
        task.resume()
    }

    
   }