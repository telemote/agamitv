//
//  LiveCell.swift
//  AgamiTV
//
//  Created by Arif Saikat on 6/2/16.
//  Copyright © 2016 Agavi TV. All rights reserved.
//

import UIKit

class LiveCell: UITableViewCell {
    
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var startsOn: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        //super.setSelected(<#T##selected: Bool##Bool#>, animated: <#T##Bool#>)
    }
    
    
}
