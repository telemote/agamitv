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
        refreshControl.addTarget(self, action: #selector(LiveTVC.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.tintColor = UIColor.whiteColor()
        return refreshControl
    }()
    
    var tabSwitch:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.addSubview(self.refreshControl)
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        activityIndicatorView.color = UIColor.whiteColor()
        tableView.backgroundView = activityIndicatorView
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.activityIndicatorView = activityIndicatorView
        
        self.tableView.backgroundColor = Constants.GREEN
        self.tableView.backgroundView!.backgroundColor = Constants.GREEN
        self.view.backgroundColor = Constants.GREEN
        
        // add app wide header
        let headerView = UIView(frame: CGRectMake(0, 0, self.view.bounds.width, 64))
        headerView.backgroundColor = Constants.RED
        let textLabel = UILabel(frame: CGRect(x: self.view.bounds.width/2-49, y: 28 , width: 100, height: 30))
        textLabel.textAlignment = .Center
        textLabel.font = UIFont.boldSystemFontOfSize(17.0)
        textLabel.attributedText = NSMutableAttributedString(
            string: "AgamiTV",
            attributes:[ NSForegroundColorAttributeName: UIColor.whiteColor()])
        headerView.addSubview(textLabel)
        self.view.addSubview(headerView)
        
        getConfigFromServer()
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
        self.activityIndicatorView.startAnimating()
        let requestURL: NSURL = NSURL(string: Constants.CONFIG_FILE_PATH)!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL,
            cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 15.0)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            if(error != nil) {
                self.activityIndicatorView.stopAnimating()
                let alert = UIAlertController(title: "Network Error", message: "Please make sure you are connected to the internet.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return;
            }

            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                self.videos.removeAll() //clear all old entries
                do{
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    
                    // load paths
                    var paths: [String] = []
                    if let entries = json["paths"] as? [String] {
                        for entry in entries {
                            paths.append(entry)
                        }
                    }
                    
                    if let entries = json["live"] as? [[String: AnyObject]] {
                        for entry in entries {
                            self.videos.append(
                                VideoResource(
                                    videoUrl: (entry["video"] as? String)?.characters.count == 0 ? "" : paths[1] + "/" + (entry["video"] as? String)!,
                                    imageUrl: paths[0] + "/" + (entry["image"] as? String)!,
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
                }catch {}
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
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.borderColor = UIColor.whiteColor().CGColor
        cell.layer.borderWidth = 3
        cell.layer.cornerRadius = 6
        cell.backgroundColor = UIColor.redColor()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("livecell") as! LiveCell
    
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
            string: videos[indexPath.section].date,
            attributes: [NSFontAttributeName:UIFont( name: "Helvetica", size: 10.0)!,
                NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        // Image loading.
        let url = NSURL(string: videos[indexPath.section].imageUrl)
        cell.imageUrl = url // For recycled cells' late image loads.
        if let image = cell.imageUrl.cachedImage {
            // Cached: set immediately.
            cell.thumbnail.image = videos[indexPath.section].videoUrl.characters.count == 0 ? image : Helper.drawPlayButtonWaterMark(inImage: image)
            cell.backGround.alpha=0
            cell.thumbnail.alpha = 1
        } else {
            // Not cached, so load then fade it in.
            cell.thumbnail.alpha = 0
            cell.backGround.image = videos[indexPath.section].videoUrl.characters.count == 0 ? UIImage(named: "noimage1.png") : Helper.drawPlayButtonWaterMark(inImage: UIImage(named: "noimage1.png")!)
            cell.backGround.alpha=1
            cell.imageUrl.fetchImage { image in
                // Check the cell hasn't recycled while loading.
                if cell.imageUrl.absoluteString == self.videos[indexPath.section].imageUrl {
                    cell.thumbnail.image = self.videos[indexPath.section].videoUrl.characters.count == 0 ? image : Helper.drawPlayButtonWaterMark(inImage: image)
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
        let v = UIView()
        v.backgroundColor = Constants.GREEN
        return v
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //CODE TO BE RUN ON CELL TOUCH
        tabSwitch = false
        if(videos[indexPath.section].videoUrl.characters.count == 0) {
            let alert = UIAlertController(title: "Live Soon", message: "Live from " + videos[indexPath.section].date , preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        let videoURL = NSURL(string: videos[indexPath.section].videoUrl)
        let player = AVPlayer(URL: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.presentViewController(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
}

