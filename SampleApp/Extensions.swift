//
//  Extensions.swift
//  SampleApp
//
//   Created by Peeyush on 18/02/21.
//  Copyright © 2021 Peeyush. All rights reserved.
//

import UIKit

extension UIView {
    
    @IBInspectable var corner: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            
            self.layer.cornerRadius = newValue
            self.clipsToBounds = true
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            
            self.layer.borderWidth = newValue
            self.clipsToBounds = true
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor.clear
        }
        set {
            
            self.layer.borderColor = newValue?.cgColor
            self.layer.borderWidth = 1.0
        }
    }
    
}
