//
//  VideoCVC.swift
//  AgamiTV
//
//  Created by Arif Saikat on 6/5/16.
//  Copyright © 2016 Agavi TV. All rights reserved.
//

import Foundation

import UIKit
import WebKit
import AVKit
import AVFoundation


    class VideoCVC: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
        
        var segmentedControl: UISegmentedControl!
        var collectionView: UICollectionView?
        weak var activityIndicatorView: UIActivityIndicatorView!

        var categoryid:String = "fashion"
        var categoryname:String = ""
        var smallbox:CGFloat = 147.0
        var mediumbox:CGFloat = 174.0
        var largebox:CGFloat = 126.0
        var margin:CGFloat = 4.0

        var videos: [VideoResource] = []
        
        override func viewDidLoad() {
            super.viewDidLoad()
            let app = UIApplication.sharedApplication()

            
            // add header
            let appheader = Helper.getAppHeder(self.view, headerText: (Helper.tabs[2] as String).uppercaseString)
            self.view.addSubview(appheader)
            
            // add video categories
            // Initialize
            let items = ["DRAMA", "FASHION", "MUSIC", "MORE"]
            segmentedControl = UISegmentedControl(items: items)
            segmentedControl.selectedSegmentIndex = 1
            
            // Set up Frame and SegmentedControl
            let frame = UIScreen.mainScreen().bounds
            segmentedControl.frame = CGRectMake(frame.minX + 10, frame.minY + app.statusBarFrame.size.height + appheader.frame.size.height + 5,frame.width - 20, 28)
            
            // Style the Segmented Control
            segmentedControl.layer.cornerRadius = 5.0  // Don't let background bleed
            segmentedControl.backgroundColor = Constants.WHITE
            segmentedControl.tintColor = Constants.RED
            
            // Add target action method
            segmentedControl.addTarget(self, action: "categoryChanged:", forControlEvents: .ValueChanged)
            
            // Add this custom Segmented Control to our view
            self.view.addSubview(segmentedControl)
            
            
            
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            
            var boxsize:CGFloat = 0.0
            
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
            
            let cframe = CGRectMake( margin + self.view.frame.origin.x ,  margin + self.view.frame.origin.y + app.statusBarFrame.size.height + appheader.frame.size.height + segmentedControl.frame.size.height + 5, self.view.frame.size.width - 2*margin, (self.view.frame.size.height - self.tabBarController!.tabBar.frame.size.height - app.statusBarFrame.size.height - appheader.frame.size.height - segmentedControl.frame.size.height - 5 - 2*margin));
            
            collectionView = UICollectionView(frame: cframe, collectionViewLayout: layout)
            
            collectionView?.setCollectionViewLayout(layout, animated: false)
            
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
            
            getConfigFromServer()
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
            cellToDeSelect.imageView.image = Helper.createUnselectedVideoImage(videos[indexPath.row].desc, inImage: cellToDeSelect.image)
        }
        
        func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
            let cellToSelect:VideoCell = collectionView.cellForItemAtIndexPath(indexPath) as! VideoCell
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
                       
            // Image loading.
            let url = NSURL(string: videos[indexPath.row].imageUrl)
            cell.imageUrl = url // For recycled cells' late image loads.
            if let image = cell.imageUrl.cachedImage {
                // Cached: set immediately.
                cell.imageView.image = Helper.createUnselectedVideoImage(self.videos[indexPath.row].desc, inImage: image)
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
                        cell.imageView.image = Helper.createUnselectedVideoImage(self.videos[indexPath.row].desc, inImage: image)
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
        
        func categoryChanged(sender: UISegmentedControl) {
            switch segmentedControl.selectedSegmentIndex
            {
            case 0:
                categoryid = "drama"
                getConfigFromServer()
                break
            case 1:
                categoryid = "fashion"
                getConfigFromServer()
                break
            case 2:
                categoryid = "music"
                getConfigFromServer()
                break
            case 3:
                categoryid = "more"
                getConfigFromServer()
                break
            default:
                break;
            }
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
                                        videoUrl: paths[1] + "/" + (entry["video"] as? String)!,
                                        imageUrl: paths[0] + "/" + (entry["image"] as? String)!,
                                        desc: (entry["desc"] as? String)!,
                                        date: (entry["date"] as? String)!
                                    )
                                )
                            }
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.collectionView!.reloadData()
                                self.activityIndicatorView.stopAnimating()
                            })
                        }
                    }catch {}
                }
            }
            task.resume()
        }
}
