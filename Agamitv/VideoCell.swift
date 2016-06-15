//
//  VideoCell.swift
//  AgamiTV
//
//  Created by Arif Saikat on 6/5/16.
//  Copyright © 2016 Agavi TV. All rights reserved.
//


import UIKit

class VideoCell: UICollectionViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //var textLabel: UILabel = UILabel()
    var imageView: UIImageView = UIImageView()
    var backGround: UIImageView = UIImageView()
    var imageUrl: NSURL!
    var image:UIImage!
    var videopath:String!
    var date:String!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backGround = UIImageView(frame: CGRect(x: 3, y: 3, width: frame.size.width-6, height: frame.size.height-6))
        //backGround.contentMode = UIViewContentMode.ScaleAspectFit
        contentView.addSubview(backGround)
        
        imageView = UIImageView(frame: CGRect(x: 3, y: 3, width: frame.size.width-6, height: frame.size.height-6))
        //imageView.contentMode = UIViewContentMode.ScaleAspectFit
        contentView.addSubview(imageView)
        
      //  textLabel = UILabel(frame: CGRect(x: 3, y: frame.size.height*2/3 + 3 , width: frame.size.width-6, height: frame.size.height/4))
      //  textLabel.numberOfLines = 0
      //  textLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
      //  textLabel.textAlignment = .Center
       // contentView.addSubview(textLabel)
    }
}
