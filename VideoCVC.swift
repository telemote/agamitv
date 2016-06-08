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
        
        var videos: [VideoResource] = []
   
        
        override func viewDidLoad() {
            super.viewDidLoad()
            navigationController?.navigationBar.translucent = false
            // Do any additional setup after loading the view, typically from a nib.
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
            layout.itemSize = CGSize(width: 114, height: 114)
            collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
            collectionView!.dataSource = self
            collectionView!.delegate = self
            collectionView!.registerClass(CollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
            collectionView!.backgroundColor = Constants.GREEN
            self.view.addSubview(collectionView!)
            getConfigFromServer()
            
            let refreshControl = UIRefreshControl()
            //refreshControl.tintColor = UIColor.blueColor()
            refreshControl.addTarget(self, action: #selector(self.refresh), forControlEvents: .ValueChanged)
            collectionView!.addSubview(refreshControl)
            collectionView!.alwaysBounceVertical = true
            
            let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
            activityIndicatorView.color = Constants.RED
            collectionView!.backgroundView = activityIndicatorView
            
            self.activityIndicatorView = activityIndicatorView
            //self.view.backgroundColor = UIColor(hue: 0.5583, saturation: 0.17, brightness: 0.88, alpha: 0.5) //must do here in

            
           // tabBar.items?[0].title = "Number 0"
        }
        
        func refresh(refreshControl: UIRefreshControl) {
            getConfigFromServer()
            refreshControl.endRefreshing()
        }
        
        func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
            //cell.layer.borderColor = UIColor.grayColor().CGColor
            //cell.layer.borderWidth = 0.3
            
            cell.layer.cornerRadius = 6
            //cell.backgroundColor = UIColor(hue: 0.5583, saturation: 0.17, brightness: 0.88, alpha: 0.5) //must do here in willDisplayCell
            cell.backgroundColor = UIColor.redColor()
           // cell.textLabel.backgroundColor = UIColor.redColor() //must do here in willDisplayCell
            //cell.textLabel.textColor = UIColor.redColor(); //can do here OR in cellForRowAtIndexPath

        }
        
        func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
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
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as! CollectionViewCell
            //cell.backgroundColor = UIColor.blackColor()
            //cell.textLabel.text = videos[indexPath.row].desc
            
          /*  var myMutableString = NSMutableAttributedString()
            var myString:NSString = videos[indexPath.row].desc
            
            myMutableString = NSMutableAttributedString(string:myString.uppercaseString as String, attributes: [NSFontAttributeName:UIFont(name: "AvenirNext", size: 6.0)!])
            myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(),
                                         range: NSRange(location:0,length:myString.length))
            
            cell.textLabel.attributedText = myMutableString */
            
            cell.textLabel.attributedText = NSMutableAttributedString(
                string: videos[indexPath.row].desc,
                attributes: [NSFontAttributeName:UIFont( name: "AvenirNext-Bold", size: 8.0)!,
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
                cell.backGround.image = Helper.drawPlayButtonWaterMark(inImage: UIImage(named: "noimageplay.png")!)
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
            
           // cell.imageView.image = Helper.drawPlayButtonWaterMark(inImage: image)
            return cell
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
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
                        self.collectionView!.reloadData()
                    })
                    do{
                        
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                        
                        if let entries = json[self.categoryid] as? [[String: AnyObject]] {
                            
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
                                self.collectionView!.reloadData()
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

        
        
}
