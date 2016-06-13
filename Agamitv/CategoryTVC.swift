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
        refreshControl.addTarget(self, action: #selector(CategoryTVC.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.tintColor = Constants.RED
        return refreshControl
    }()
    
    var tabSwitch:Bool = false
    var categoryid:String = ""
    var categoryname:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.addSubview(self.refreshControl)
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        activityIndicatorView.color = Constants.RED
        
        self.tableView.backgroundView = activityIndicatorView
        self.activityIndicatorView = activityIndicatorView
        
       // self.tableView.backgroundColor = Constants.GREEN
       // self.tableView.backgroundView!.backgroundColor = Constants.GREEN
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.view.backgroundColor = Constants.WHITE
        
        self.navigationController!.navigationBar.translucent = false
        self.navigationController!.navigationBar.barTintColor = Constants.WHITE
        self.navigationController!.navigationBar.tintColor = Constants.RED
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Constants.RED]
        self.navigationItem.title = "VIDEOS"
        
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
        NSURLCache.sharedURLCache().removeAllCachedResponses()
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
                self.categories.removeAll() //clear all old entries
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let destinationVC = segue.destinationViewController as! VideoCVC
        destinationVC.categoryid = self.categoryid
        destinationVC.categoryname = self.categoryname
    }
  
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("categorycell")! as UITableViewCell
        
        cell.textLabel!.textAlignment = NSTextAlignment.Center;
        cell.textLabel!.attributedText = NSMutableAttributedString(
            string: categories[indexPath.section].display.uppercaseString,
            attributes: [NSFontAttributeName:UIFont( name: "AvenirNext-Bold", size: 18.0)!,
                NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        // add border and color
        cell.backgroundColor = Constants.GREEN
        cell.layer.borderColor = Constants.GREEN.CGColor
        cell.layer.borderWidth = 3
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
  
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
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cellToDeSelect:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        //cellToDeSelect.layer.borderColor = Constants.RED.CGColor
        cellToDeSelect.backgroundColor = Constants.GREEN
        cellToDeSelect.layer.borderColor = Constants.GREEN.CGColor
    }
    
    // method to run when table view cell is tapped
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tabSwitch = false
        let selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        //selectedCell.layer.borderColor = UIColor.whiteColor().CGColor
        selectedCell.backgroundColor = Constants.RED
        selectedCell.layer.borderColor = Constants.RED.CGColor
        self.categoryid = categories[indexPath.section].id
        self.categoryname = categories[indexPath.section].display
        performSegueWithIdentifier("category", sender: self)
    }
}
