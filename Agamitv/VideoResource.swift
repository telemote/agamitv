//
//  VideoResource.swift
//  Agamitv
//
//  Created by Arif Saikat on 5/27/16.
//  Copyright © 2016 Agavi TV. All rights reserved.
//

import UIKit
import Foundation

class VideoResource {
    var videoUrl:String = ""
    var imageUrl:String = ""  // image 300 x 300
    var desc:String = ""  // about 80 chars
    var date:String = ""
   // var imageData:NSData
    
    
    init(videoUrl:String, imageUrl:String, desc:String, date:String) {
        self.videoUrl = videoUrl
        self.desc = desc
        self.date = date
        self.imageUrl = imageUrl
       //let url = NSURL(string: imageUrl)
       // self.imageData = NSData(contentsOfURL: url!)! //make sure your image in this url does exist, otherwise unwrap in a if let check
        
        
    }
}
