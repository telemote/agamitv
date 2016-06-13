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


class EventTVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    weak var activityIndicatorView: UIActivityIndicatorView!
    var videos: [VideoResource] = []
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(EventTVC.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.tintColor = Constants.RED
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.addSubview(self.refreshControl)
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        activityIndicatorView.color = Constants.RED
        tableView.backgroundView = activityIndicatorView
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.activityIndicatorView = activityIndicatorView
        
        //self.tableView.backgroundColor = Constants.GREEN
        //self.tableView.backgroundView!.backgroundColor = Constants.GREEN
        //self.view.backgroundColor = Constants.GREEN
        self.view.backgroundColor = Constants.WHITE
        
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
       // self.view.addSubview(headerView)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        getConfigFromServer()
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
                    
                    if let entries = json["events"] as? [[String: AnyObject]] {
                        for entry in entries {
                            self.videos.append(
                                VideoResource(
                                    videoUrl: "",
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
    
    var tabSwitch:Bool = true

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("eventcell") as! EventCell
        cell.desc?.numberOfLines = 0
        cell.desc?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.desc?.font = cell.desc?.font.fontWithSize(16)
        cell.desc.attributedText = NSMutableAttributedString(
            string: videos[indexPath.section].desc,
            attributes: [NSFontAttributeName:UIFont( name: "Helvetica", size: 11.0)!,
                NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        cell.eventOn.attributedText = NSMutableAttributedString(
            string: videos[indexPath.section].date,
            attributes: [NSFontAttributeName:UIFont( name: "Helvetica-Bold", size: 13.0)!,
                NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        // Image loading.
        let url = NSURL(string: videos[indexPath.row].imageUrl)
        cell.imageUrl = url // For recycled cells' late image loads.
        if let image = cell.imageUrl.cachedImage {
            // Cached: set immediately.
            cell.thumbnail.image = image
            cell.backGround.alpha=0
            cell.thumbnail.alpha = 1
        } else {
            // Not cached, so load then fade it in.
            cell.thumbnail.alpha = 0
            cell.backGround.image = UIImage(named: "300300.png")!
            cell.backGround.alpha=1
            cell.imageUrl.fetchImage { image in
                // Check the cell hasn't recycled while loading.
                if cell.imageUrl.absoluteString == self.videos[indexPath.row].imageUrl {
                    cell.thumbnail.image = image
                    UIView.animateWithDuration(0.3) {
                        cell.backGround.alpha=0
                        cell.thumbnail.alpha = 1
                    }
                }
            }
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.borderColor = UIColor.whiteColor().CGColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 12
        cell.backgroundColor = Constants.GREEN
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
        //v.backgroundColor = Constants.GREEN
        return v
    }
}

