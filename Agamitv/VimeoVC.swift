//
//  VimeoVC.swift
//  Agamitv
//
//  Created by Arif Saikat on 5/30/16.
//  Copyright © 2016 Agavi TV. All rights reserved.
//

import UIKit
import WebKit


class VimeoVC: UIViewController, UIWebViewDelegate {
    
    
    @IBOutlet var vimeo: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
       super.viewDidLoad()
       
        var embedHTML="<html><head><style type=\"text/css\">body {background-color: transparent;color: white;}</style></head><body style=\"margin:0\"><iframe src=\"//player.vimeo.com/video/113067409?autoplay=1&amp;loop=1\"  frameborder=\"0\" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>";
        
        vimeo.delegate = self
        var url: NSURL = NSURL(string: "http://")!
        vimeo.loadHTMLString(embedHTML as String, baseURL:url )
        
        // Do any additional setup after loading the view, typically from a nib.
       // let url = NSURL (string: "https://vimeo.com/168145284");
       // let requestObj = NSURLRequest(URL: url!);
       // vimeo.loadRequest(requestObj);
        
        
    
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
