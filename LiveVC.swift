//
//  LiveVC.swift
//  Agamitv
//
//  Created by Arif Saikat on 5/28/16.
//  Copyright © 2016 Agavi TV. All rights reserved.
//

import UIKit

class LiveVC: UIViewController {

    @IBOutlet weak var player: YTPlayerView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        getConfigFromServer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onReloadLiveStream(sender: AnyObject) {
        getConfigFromServer()
    }
    func getConfigFromServer(){
        let requestURL: NSURL = NSURL(string: Constants.CONFIG_FILE_PATH)!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                print("Everyone is fine, file downloaded successfully.")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.player.hidden = true
                })

                do{
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    if let entries = json["live"] as? [[String: AnyObject]] {
                    var noStream:Bool = true
                    for entry in entries {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.player.hidden = false
                            self.player.loadWithVideoId((entry["id"] as? String)!)
                        })
                        noStream = false
                        break
                    }
                        
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if(noStream) {
                            let alertController = UIAlertController(title: "Stream Unavailable", message:
                                "No Live Stream Available Right Now!", preferredStyle: UIAlertControllerStyle.Alert)
                            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                            
                            self.presentViewController(alertController, animated: true, completion: nil)
                        }
                    })
                    
                }
                }catch {
                    print("Error with Json: \(error)")
                }
            }
        }
        task.resume()
    }
    
}
