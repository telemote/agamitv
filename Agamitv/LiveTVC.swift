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

class LiveTVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
        activityIndicatorView.color = Constants.RED
        tableView.backgroundView = activityIndicatorView
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        //tableView.separatorColor = Constants.GREEN
        //tableView.separatorInset
        self.activityIndicatorView = activityIndicatorView
        
        self.tableView.backgroundColor = Constants.GREEN
        self.tableView.backgroundView!.backgroundColor = Constants.GREEN
        self.view.backgroundColor = Constants.GREEN
        
        
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
                    
                    if let entries = json["event"] as? [[String: AnyObject]] {
                        
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
    
   /* func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0;
    }*/
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.borderColor = UIColor.whiteColor().CGColor
        cell.layer.borderWidth = 3
        
        cell.layer.cornerRadius = 6
        //cell.backgroundColor = UIColor(hue: 0.5583, saturation: 0.17, brightness: 0.88, alpha: 0.5) //must do here in willDisplayCell
        cell.backgroundColor = UIColor.redColor()
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("livecell") as! LiveCell
        /* if(videos.count == 0) {
        return cell
        }*/
        
        cell.desc?.numberOfLines = 0
        cell.desc?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.desc?.font = cell.desc?.font.fontWithSize(16)
        cell.desc.attributedText = NSMutableAttributedString(
            string: videos[indexPath.section].desc,
            attributes: [NSFontAttributeName:UIFont( name: "Helvetica-Bold", size: 13.0)!,
            NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        cell.addedOn?.font = cell.addedOn?.font.fontWithSize(11)
        //cell.addedOn.text = "Added on " + videos[indexPath.row].date
        cell.addedOn.attributedText = NSMutableAttributedString(
            string: "Added on " + videos[indexPath.section].date,
            attributes: [NSFontAttributeName:UIFont( name: "Helvetica", size: 10.0)!,
                NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        // Image loading.
        let url = NSURL(string: videos[indexPath.section].imageUrl)
        cell.imageUrl = url // For recycled cells' late image loads.
        if let image = cell.imageUrl.cachedImage {
            // Cached: set immediately.
            cell.thumbnail.image = Helper.drawPlayButtonWaterMark(inImage: image)
            cell.backGround.alpha=0
            cell.thumbnail.alpha = 1
        } else {
            // Not cached, so load then fade it in.
            cell.thumbnail.alpha = 0
            cell.backGround.image = Helper.drawPlayButtonWaterMark(inImage: UIImage(named: "noimageplay.png")!)
            cell.backGround.alpha=1
            cell.imageUrl.fetchImage { image in
                // Check the cell hasn't recycled while loading.
                if cell.imageUrl.absoluteString == self.videos[indexPath.section].imageUrl {
                    cell.thumbnail.image = Helper.drawPlayButtonWaterMark(inImage: image)
                    UIView.animateWithDuration(0.3) {
                        cell.backGround.alpha=0
                        cell.thumbnail.alpha = 1
                    }
                }
            }
        }
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return videos.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var v = UIView()
        v.backgroundColor = Constants.GREEN
        return v
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //CODE TO BE RUN ON CELL TOUCH
        tabSwitch = false
        let videoURL = NSURL(string: videos[indexPath.section].videoUrl)
        let player = AVPlayer(URL: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.presentViewController(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
}

