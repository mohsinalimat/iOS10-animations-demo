//
//  DotView.swift
//  LoginAnimation
//
//  Created by Olga Konoreva on 30/09/16.
//  Copyright © 2016 Olga Konoreva. All rights reserved.
//

import UIKit

let kDotSize: CGFloat = 15

class DotView: UIView {
    
    private var color: UIColor
    
    init(color: UIColor) {
        self.color = color
        super.init(frame: CGRect(x: 0, y: 0, width: kDotSize, height: kDotSize))
        clipsToBounds = true
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        context.setFillColor(color.cgColor)
        context.addEllipse(in: bounds)
        context.drawPath(using: .fill)
    }
}


