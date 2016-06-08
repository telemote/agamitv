//
//  CollectionViewCell.swift
//  UICollectionView
//
//  Created by Brian Coleman on 2014-09-04.
//  Copyright (c) 2014 Brian Coleman. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var textLabel: UILabel = UILabel()
    var imageView: UIImageView = UIImageView()
    var backGround: UIImageView = UIImageView()
    var imageUrl: NSURL!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backGround = UIImageView(frame: CGRect(x: 3, y: 3, width: frame.size.width-6, height: frame.size.height*2/3))
        backGround.contentMode = UIViewContentMode.ScaleAspectFit
        //backGround.layer.cornerRadius = 8
        contentView.addSubview(backGround)
        
        imageView = UIImageView(frame: CGRect(x: 3, y: 3, width: frame.size.width-6, height: frame.size.height*2/3))
        //imageView.contentMode = UIViewContentMode.ScaleAspectFit
        //imageView.layer.cornerRadius = 8
        contentView.addSubview(imageView)
        
        let textFrame = CGRect(x: 3, y: frame.size.height*2/3 + 3 , width: frame.size.width-6, height: frame.size.height/4)
        textLabel = UILabel(frame: textFrame)
        //textLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        //textLabel.font = textLabel.font.fontWithSize(16)
        

        
        
        textLabel.textAlignment = .Center
        contentView.addSubview(textLabel)
    }
}
