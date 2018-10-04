//
//  Label.swift
//  CameraObjectDetection
//
//  Created by Felipe Kimio Nishikaku on 16/09/18.
//  Copyright © 2018 Felipe Kimio Nishikaku. All rights reserved.
//

import UIKit

class Label: UILabel {
    
    var padding: CGFloat = 0
    
    override func drawText(in rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        let rectInsets: CGRect = rect.inset(by: insets)
        let newRect: CGRect = CGRect(x: insets.left,
                             y: 0,
                             width: rectInsets.size.width,
                             height: rect.height)
        
        frame = CGRect(x: frame.origin.x,
                       y: frame.origin.y,
                       width: frame.size.width,
                       height: frame.size.height + insets.bottom + insets.top)
        super.drawText(in: newRect)
    }
}
