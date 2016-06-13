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
        
        @IBOutlet var collectionView: UICollectionView?
        weak var activityIndicatorView: UIActivityIndicatorView!

        var categoryid:String = ""
        var categoryname:String = ""
        var smallbox:CGFloat = 150.0
        var mediumbox:CGFloat = 168.0
        var largebox:CGFloat = 128.0
        var fontsize:CGFloat = 7.0
        var margin:CGFloat = 4.0

        var videos: [VideoResource] = []
        
        override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        let top = self.topLayoutGuide.length;
        let bottom = self.bottomLayoutGuide.length;
        let newInsets = UIEdgeInsetsMake(top, 0, bottom, 0);
        self.collectionView!.contentInset = newInsets;
        
        }
   
        
        override func viewDidLoad() {
            super.viewDidLoad()
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            
            var boxsize:CGFloat = 0.0
            var marginsize:CGFloat = 0.0

            
            // for iphone 6 plus and 6s plus
            if(self.view.frame.width >= (largebox+margin)*3) {
                boxsize = largebox
                marginsize = margin
                fontsize = 7.0
                }
            //for iphone 6 and 6 plus
            else if(self.view.frame.width >= (mediumbox+margin*3)*2){
                boxsize = mediumbox
                marginsize = margin*3
                fontsize = 9.0
            }
            //for iphone 4s, 5 and 5s
            else {
                boxsize = smallbox
                marginsize = margin
                fontsize = 8.0
            }
            layout.sectionInset = UIEdgeInsets(top: marginsize, left: marginsize, bottom: marginsize, right: marginsize)
            layout.itemSize = CGSize(width: boxsize, height: boxsize)
            
            let frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, (self.view.frame.size.height - self.tabBarController!.tabBar.frame.size.height-boxsize*3/7));

            collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
           // collectionView = UICollectionView(frame: CGRect(x: 0, y: 0 , width: self.view.frame.width, height: self.view.frame.height/*-self.tabBarController!.tabBar.frame.size.height*/), collectionViewLayout: layout)
            
            collectionView!.dataSource = self
            collectionView!.delegate = self
            collectionView!.registerClass(VideoCell.self, forCellWithReuseIdentifier: "videocell")
            collectionView!.backgroundColor = Constants.WHITE
            collectionView?.alwaysBounceVertical = true
            //collectionView?.alwaysBounceHorizontal = true
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
            self.navigationItem.title = categoryname.uppercaseString
            //self.edgesForExtendedLayout = UIRectEdgeNone;
            //self.extendedLayoutIncludesOpaqueBars = false;
            //self.automaticallyAdjustsScrollViewInsets = false;
            self.tabBarController!.tabBar.translucent = false
            
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
            let cellToDeSelect:UICollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath)!
            cellToDeSelect.backgroundColor = Constants.GREEN
        }
        
        func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
            let cellToSelect:UICollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath)!
            cellToSelect.backgroundColor = Constants.RED
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
            cell.textLabel.attributedText = NSMutableAttributedString(
                string: videos[indexPath.row].desc,
                attributes: [NSFontAttributeName:UIFont( name: "AvenirNext-Bold", size: fontsize)!,
                    NSForegroundColorAttributeName: UIColor.whiteColor()])
            
            // Image loading.
            let url = NSURL(string: videos[indexPath.row].imageUrl)
            cell.imageUrl = url // For recycled cells' late image loads.
            if let image = cell.imageUrl.cachedImage {
                // Cached: set immediately.
                cell.imageView.image = Helper.drawPlayButtonWaterMark(inImage: image)
                cell.backGround.alpha=0
                cell.imageView.alpha = 1
            } else {
                // Not cached, so load then fade it in.
                cell.imageView.alpha = 0
                cell.backGround.image = Helper.drawPlayButtonWaterMark(inImage: UIImage(named: "300200.png")!)
                cell.backGround.alpha=1
                cell.imageUrl.fetchImage { image in
                    // Check the cell hasn't recycled while loading.
                    if cell.imageUrl.absoluteString == self.videos[indexPath.row].imageUrl {
                        cell.imageView.image = Helper.drawPlayButtonWaterMark(inImage: image)
                        UIView.animateWithDuration(0.3) {
                            cell.backGround.alpha=0
                            cell.imageView.alpha = 1
                        }
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
