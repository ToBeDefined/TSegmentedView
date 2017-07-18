//
//  Extension.swift
//  TSegmentedView
//
//  Created by 邵伟男 on 2017/7/18.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(R: Int, G: Int, B: Int, A: Float = 1.0) {
        self.init(red:   CGFloat(Float(R) / 255.0),
                  green: CGFloat(Float(G) / 255.0),
                  blue:  CGFloat(Float(B) / 255.0),
                  alpha: CGFloat(A))
    }
    
    convenience init(withRGBValue rgbValue: Int, alpha: Float = 1.0) {
        let r = ((rgbValue & 0xFF0000) >> 16)
        let g = ((rgbValue & 0x00FF00) >> 8)
        let b =  (rgbValue & 0x0000FF)
        self.init(R: r,
                  G: g,
                  B: b,
                  A: alpha)
    }
}

extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContext(rect.size)
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

