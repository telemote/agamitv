//
//  CategoryTVC.swift
//  AgamiTV
//
//  Created by Arif Saikat on 6/7/16.
//  Copyright © 2016 Agavi TV. All rights reserved.
//




import Foundation

import UIKit
import WebKit
import AVKit
import AVFoundation

class CategoryTVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
   @IBOutlet weak var tableView: UITableView!
    weak var activityIndicatorView: UIActivityIndicatorView!
    var categories: [Category] = []
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
        
        self.tableView.backgroundColor = Constants.GREEN
        self.tableView.backgroundView!.backgroundColor = Constants.GREEN
        self.view.backgroundColor = Constants.GREEN
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
                    self.categories.removeAll() //clear all old entries
                    self.tableView.reloadData()
                })
                do{
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    
                    if let entries = json["categories"] as? [[String: AnyObject]] {
                        
                        for entry in entries {
                            
                            self.categories.append(
                                Category(
                                    display: (entry["display"] as? String)!,
                                    id: (entry["id"] as? String)!
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        
        
        // Create a new variable to store the instance of PlayerTableViewController
        let destinationVC = segue.destinationViewController as! VideoCVC
        destinationVC.categoryid = self.categoryid
    }
    

    
    // if tableView is set in attribute inspector with selection to multiple Selection it should work.
    
    // Just set it back in deselect
    


    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("categorycell")! as UITableViewCell
        
        // note that indexPath.section is used rather than indexPath.row
        //cell.textLabel?.text = self.categories[indexPath.section].display
        
        cell.textLabel!.textAlignment = NSTextAlignment.Center;
        
        
        var myMutableString = NSMutableAttributedString()
        var myString:NSString = categories[indexPath.section].display
        
        myMutableString = NSMutableAttributedString(string:myString.uppercaseString as String, attributes: [NSFontAttributeName:UIFont(name: "AvenirNext-Bold", size: 18.0)!])
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(),
                                     range: NSRange(location:0,length:myString.length))
       
        cell.textLabel!.attributedText = myMutableString
        
       /* cell.textLabel!.attributedText = NSMutableAttributedString(
            string: categories[indexPath.section].display,
            attributes: [NSFontAttributeName:UIFont(
                name: "Helvetica-Bold",
                color : [UIColor redColor],
                size: 16.0)!])*/
        
        // add border and color
        cell.backgroundColor = Constants.RED
        cell.layer.borderColor = Constants.RED.CGColor
        cell.layer.borderWidth = 3
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        
       // cell.textLabel!.text = categories[indexPath.row].display
        
      //  cell.contentView.backgroundColor = UIColor.whiteColor()
       // cell.backgroundColor = UIColor.redColor()
        /* if(videos.count == 0) {
         return cell
         }*/
        
       /* cell.desc?.numberOfLines = 0
        cell.desc?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.desc?.font = cell.desc?.font.fontWithSize(16)
        cell.desc.attributedText = NSMutableAttributedString(
            string: videos[indexPath.row].desc,
            attributes: [NSFontAttributeName:UIFont(
                name: "Helvetica-Bold",
                size: 13.0)!])
        
        cell.addedOn?.font = cell.addedOn?.font.fontWithSize(11)
        cell.addedOn.text = "Added on " + videos[indexPath.row].date
        
        // Image loading.
        let url = NSURL(string: videos[indexPath.row].imageUrl)
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
                if cell.imageUrl.absoluteString == self.videos[indexPath.row].imageUrl {
                    cell.thumbnail.image = Helper.drawPlayButtonWaterMark(inImage: image)
                    UIView.animateWithDuration(0.3) {
                        cell.backGround.alpha=0
                        cell.thumbnail.alpha = 1
                    }
                }
            }
        }
        */
        return cell
    }
    
    // have one section for every array item
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return categories.count
    }
    
    // There is just one row in every section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Set the spacing between sections
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    // Make the background color show through
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clearColor()
        return headerView
    }

    
    
   /* func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }*/
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        var cellToDeSelect:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
       // cellToDeSelect.contentView.backgroundColor = UIColor.lightGrayColor()
        cellToDeSelect.layer.borderColor = Constants.RED.CGColor
    }
    
    var categoryid:String = ""
    
    // method to run when table view cell is tapped
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // note that indexPath.section is used rather than indexPath.row
        print("You tapped cell number \(indexPath.section).")
        
        var selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        //selectedCell.contentView.backgroundColor = self.view.tintColor
        //selectedCell.contentView.backgroundColor = UIColor(red:14, green: 86, blue: 43)
        //selectedCell.textLabel?.attributedText.
        selectedCell.layer.borderColor = UIColor.whiteColor().CGColor
        tabSwitch = false
        self.categoryid = categories[indexPath.section].id
        performSegueWithIdentifier("category", sender: self)
    }
    
    /*func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //CODE TO BE RUN ON CELL TOUCH
        tabSwitch = false
        self.categoryid = categories[indexPath.row].id
        performSegueWithIdentifier("category", sender: self)

        
        let videoURL = NSURL(string: videos[indexPath.row].videoUrl)
        let player = AVPlayer(URL: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.presentViewController(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }*/
}
