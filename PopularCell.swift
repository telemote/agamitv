//
//  PopularCell.swift
//  Agamitv
//
//  Created by Arif Saikat on 5/28/16.
//  Copyright © 2016 Agavi TV. All rights reserved.
//

import UIKit

class PopularCell: UITableViewCell {

    @IBOutlet weak var backGround: UIImageView!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var addedOn: UILabel!
    var imageUrl: NSURL!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        //super.setSelected(<#T##selected: Bool##Bool#>, animated: <#T##Bool#>)
    }
    
    
}
