//
//  RecentCVC.swift
//  AgamiTV
//
//  Created by Arif Saikat on 6/13/16.
//  Copyright © 2016 Agavi TV. All rights reserved.
//

import Foundation

import UIKit
import WebKit
import AVKit
import AVFoundation


class LiveCVC: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var collectionView: UICollectionView?
    var activityIndicatorView: UIActivityIndicatorView!
    
    let categoryid:String = "live"
    let smallbox:CGFloat = 147.0
    let mediumbox:CGFloat = 174.0
    let largebox:CGFloat = 126.0
    let margin:CGFloat = 4.0
    var videos: [VideoResource] = []
    var tabSwitch = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add header
        let appheader = Helper.getAppHeder(self.view, headerText: (Helper.tabs[2] as String).uppercaseString)
        self.view.addSubview(appheader)
        
        
        var boxsize:CGFloat = 0.0
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        // for iphone 6 plus and 6s plus
        if(self.view.frame.width >= (largebox+margin)*3) {
            boxsize = largebox
        }
            //for iphone 6 and 6 plus
        else if(self.view.frame.width >= (mediumbox+margin)*2){
            boxsize = mediumbox
        }
            //for iphone 4s, 5 and 5s
        else {
            boxsize = smallbox
        }
        
        layout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        layout.itemSize = CGSize(width: boxsize, height: boxsize)
        
        let app = UIApplication.sharedApplication()
        let frame = CGRectMake( margin + self.view.frame.origin.x ,  margin + self.view.frame.origin.y + app.statusBarFrame.size.height + appheader.frame.size.height, self.view.frame.size.width - 2*margin, (self.view.frame.size.height - self.tabBarController!.tabBar.frame.size.height - app.statusBarFrame.size.height - appheader.frame.size.height - 2*margin));
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        
        collectionView!.dataSource = self
        collectionView!.delegate = self
        collectionView!.registerClass(VideoCell.self, forCellWithReuseIdentifier: "videocell")
        collectionView!.backgroundColor = Constants.WHITE
        collectionView?.alwaysBounceVertical = true
        self.view.addSubview(collectionView!)
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = Constants.RED
        refreshControl.addTarget(self, action: #selector(self.refresh), forControlEvents: .ValueChanged)
        collectionView!.addSubview(refreshControl)
        collectionView!.alwaysBounceVertical = true
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        activityIndicatorView.color = Constants.RED
        collectionView!.backgroundView = activityIndicatorView
        self.activityIndicatorView = activityIndicatorView
        
        // load config
        //getConfigFromServer()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if(tabSwitch == true) {
            getConfigFromServer()
        }else {
            tabSwitch = true
        }
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        getConfigFromServer()
        refreshControl.endRefreshing()
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        cell.layer.cornerRadius = 6
        cell.backgroundColor = Constants.GREEN
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cellToDeSelect:VideoCell = collectionView.cellForItemAtIndexPath(indexPath) as! VideoCell
        cellToDeSelect.backgroundColor = Constants.GREEN
        cellToDeSelect.imageView.image = cellToDeSelect.videopath.characters.count == 0 ? Helper.createNoPlayVideoImage(self.videos[indexPath.row].desc, inImage: cellToDeSelect.image) : Helper.createUnselectedVideoImage(videos[indexPath.row].desc, inImage: cellToDeSelect.image)
    
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        tabSwitch = false
        let cellToSelect:VideoCell = collectionView.cellForItemAtIndexPath(indexPath) as! VideoCell
        if(cellToSelect.videopath.characters.count == 0) {
            
            let alert = UIAlertController(title: nil, message: cellToSelect.date , preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            getConfigFromServer() // reload to get feed update
            return
        }
        
        
        cellToSelect.backgroundColor = Constants.RED
        cellToSelect.imageView.image = Helper.createSelectedVideoImage(videos[indexPath.row].desc, inImage: cellToSelect.image)
        let videoURL = NSURL(string: videos[indexPath.row].videoUrl)
        let player = AVPlayer(URL: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.presentViewController(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("videocell", forIndexPath: indexPath) as! VideoCell
        
        cell.videopath = videos[indexPath.row].videoUrl
        cell.date = videos[indexPath.row].date
        
        // Image loading.
        let url = NSURL(string: videos[indexPath.row].imageUrl)
        cell.imageUrl = url // For recycled cells' late image loads.
        if let image = cell.imageUrl.cachedImage {
            // Cached: set immediately.
            //cell.imageView.image = Helper.drawPlayButtonWaterMark(inImage: image)
            cell.imageView.image = videos[indexPath.row].videoUrl.characters.count == 0 ? Helper.createNoPlayVideoImage(videos[indexPath.row].desc, inImage: image) : Helper.createUnselectedVideoImage(videos[indexPath.row].desc, inImage: image)
            cell.backGround.alpha=0
            cell.imageView.alpha = 1
            cell.image = image
        } else {
            // Not cached, so load then fade it in.
            cell.imageView.alpha = 0
            cell.backGround.image = UIImage(named: "300300.png")
            cell.backGround.alpha=1
            cell.imageUrl.fetchImage { image in
                // Check the cell hasn't recycled while loading.
                if cell.imageUrl.absoluteString == self.videos[indexPath.row].imageUrl {
                    //cell.imageView.image = Helper.drawPlayButtonWaterMark(inImage: image)
                    cell.imageView.image = self.videos[indexPath.row].videoUrl.characters.count == 0 ? Helper.createNoPlayVideoImage(self.videos[indexPath.row].desc, inImage: image) : Helper.createUnselectedVideoImage(self.videos[indexPath.row].desc, inImage: image)
                    UIView.animateWithDuration(0.3) {
                        cell.backGround.alpha=0
                        cell.imageView.alpha = 1
                    }
                    cell.image = image
                }
            }
        }
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                    let liveevents = json["live"] as? [[String: AnyObject]]
                    let events = json["events"] as? [[String: AnyObject]]
                    
                    // load paths
                    var paths: [String] = []
                    if let entries = json["paths"] as? [String] {
                        for entry in entries {
                            paths.append(entry)
                        }
                    }
                    
                    
                    if let entries = json[self.categoryid] as? [[String: AnyObject]] {
                        for entry in entries {
                            self.videos.append(
                                VideoResource(
                                    videoUrl: (entry["video"] as? String)!,
                                    imageUrl: (entry["image"] as? String)!,
                                    desc: (entry["desc"] as? String)!,
                                    date: (entry["date"] as? String)!
                                )
                            )
                        }
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.collectionView!.reloadData()
                            self.activityIndicatorView.stopAnimating()
                            
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
                    }
                }catch {}
            }
        }
        task.resume()
    }
}
