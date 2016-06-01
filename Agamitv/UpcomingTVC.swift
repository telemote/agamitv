//
//  UpcomingTVC.swift
//  Agamitv
//
//  Created by Arif Saikat on 5/31/16.
//  Copyright © 2016 Agavi TV. All rights reserved.
//


import Foundation

import UIKit
import WebKit
import AVKit
import AVFoundation


class UpcomingTVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    weak var activityIndicatorView: UIActivityIndicatorView!
    var videos: [VideoResource] = []
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.addSubview(self.refreshControl)
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        activityIndicatorView.color = UIColor.blueColor()
        tableView.backgroundView = activityIndicatorView
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.activityIndicatorView = activityIndicatorView
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
                    self.activityIndicatorView.startAnimating()
                    self.videos.removeAll() //clear all old entries
                    self.tableView.reloadData()
                })
                do{
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    
                    if let entries = json["upcoming"] as? [[String: AnyObject]] {
                        
                        for entry in entries {
                            
                            self.videos.append(
                                VideoResource(
                                    videoUrl: "",
                                    imageUrl: Constants.IMAGE_BASE_PATH + (entry["image"] as? String)!,
                                    desc: (entry["desc"] as? String)!,
                                    date: (entry["date"] as? String)!
                                )
                            )
                        }
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tableView.reloadData()
                            self.activityIndicatorView.stopAnimating()
                        })
                        
                    }
                }catch {
                    print("Error with Json: \(error)")
                }
            }
        }
        task.resume()
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        getConfigFromServer()
        refreshControl.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("upcomingcell") as! UpcomingCell
        /* if(videos.count == 0) {
        return cell
        }*/
        
        cell.desc?.numberOfLines = 0
        cell.desc?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.desc?.font = cell.desc?.font.fontWithSize(16)
        cell.desc.attributedText = NSMutableAttributedString(
            string: videos[indexPath.row].desc,
            attributes: [NSFontAttributeName:UIFont(
                name: "Helvetica",
                size: 11.0)!])
        
        cell.eventOn.attributedText = NSMutableAttributedString(
            string: videos[indexPath.row].date,
            attributes: [NSFontAttributeName:UIFont(
                name: "Helvetica-bold",
                size: 13.0)!])
        
       // cell.eventOn?.font = cell.eventOn?.font.fontWithSize(11)
        //cell.eventOn.text = "Event on " + videos[indexPath.row].date
        
        let url = NSURL(string: videos[indexPath.row].imageUrl)
        let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
        cell.thumbnail.image = UIImage(data: data!)
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //CODE TO BE RUN ON CELL TOUCH
    }
}

