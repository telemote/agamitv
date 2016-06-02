//
//  RecentTVC.swift
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

class RecentTVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    weak var activityIndicatorView: UIActivityIndicatorView!
    var videos: [VideoResource] = []
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        return refreshControl
    }()
    
    var tabSwitch:Bool = true
    
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
        if(tabSwitch) {
            getConfigFromServer()
        } else {
            tabSwitch = true
        }
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
                    
                    if let entries = json["recent"] as? [[String: AnyObject]] {
                        
                        for entry in entries {
                            
                            self.videos.append(
                                VideoResource(
                                    videoUrl: Constants.VIDEO_BASE_PATH + (entry["video"] as? String)!,
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
        let cell = tableView.dequeueReusableCellWithIdentifier("recentcell") as! RecentCell
        /* if(videos.count == 0) {
        return cell
        }*/
        
        cell.desc?.numberOfLines = 0
        cell.desc?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.desc?.font = cell.desc?.font.fontWithSize(16)
        cell.desc.attributedText = NSMutableAttributedString(
            string: videos[indexPath.row].desc,
            attributes: [NSFontAttributeName:UIFont(
                name: "Helvetica-Bold",
                size: 13.0)!])
        
        cell.addedOn?.font = cell.addedOn?.font.fontWithSize(11)
        cell.addedOn.text = "Added on " + videos[indexPath.row].date
        
        let url = NSURL(string: videos[indexPath.row].imageUrl)
        let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
        let backgroundImage = UIImage(data: data!)
        let foreGroundImage = UIImage(named: "play.png")
        let point = CGPoint(x: (backgroundImage?.size.width)!/2-(foreGroundImage?.size.width)!/2,
                            y: (backgroundImage?.size.height)!/2-(foreGroundImage?.size.height)!/2)
        cell.thumbnail.image = drawImage(image: foreGroundImage!, inImage: backgroundImage!, atPoint: point)
         //cell.thumbnail.image = UIImage(data: data!)
        
        return cell
    }
    
     func drawImage(image foreGroundImage:UIImage, inImage backgroundImage:UIImage, atPoint point:CGPoint) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(backgroundImage.size, false, 0.0)
        backgroundImage.drawInRect(CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height))
        foreGroundImage .drawInRect(CGRectMake(point.x, point.y, foreGroundImage.size.width, foreGroundImage.size.height), blendMode: CGBlendMode.Normal, alpha: 0.8)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //CODE TO BE RUN ON CELL TOUCH
        tabSwitch = false
        let videoURL = NSURL(string: videos[indexPath.row].videoUrl)
        let player = AVPlayer(URL: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.presentViewController(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
}

