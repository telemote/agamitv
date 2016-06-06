//
//  RoundedCornersView.swift
//  AgamiTV
//
//  Created by Arif Saikat on 6/5/16.
//  Copyright © 2016 Agavi TV. All rights reserved.
//


import UIKit

@IBDesignable
class RoundedCornersView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }

}
