//
//  Extension.swift
//  TSegmentedView
//
//  Created by 邵伟男 on 2017/7/18.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit

#if swift(>=4.2)
typealias TSVLayoutConstraintAttribute = NSLayoutConstraint.Attribute
#else
typealias TSVLayoutConstraintAttribute = NSLayoutAttribute
#endif

extension UIColor {
    convenience init(tsvR: Int, tsvG: Int, tsvB: Int, tsvA: Float = 1.0) {
        self.init(red:   CGFloat(Float(tsvR) / 255.0),
                  green: CGFloat(Float(tsvG) / 255.0),
                  blue:  CGFloat(Float(tsvB) / 255.0),
                  alpha: CGFloat(tsvA))
    }
    
    convenience init(withTSVRGBValue rgbValue: Int, alpha: Float = 1.0) {
        let r = ((rgbValue & 0xFF0000) >> 16)
        let g = ((rgbValue & 0x00FF00) >> 8)
        let b =  (rgbValue & 0x0000FF)
        self.init(tsvR: r,
                  tsvG: g,
                  tsvB: b,
                  tsvA: alpha)
    }
}

extension UIImage {
    convenience init?(tsvcolor: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContext(rect.size)
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(tsvcolor.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}


extension UIView {
    @discardableResult
    func tsv_makeConstraint(_ attribute: TSVLayoutConstraintAttribute,
                            is number: CGFloat) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint.init(item: self,
                                                 attribute: attribute,
                                                 relatedBy: .equal,
                                                 toItem: nil,
                                                 attribute: .notAnAttribute,
                                                 multiplier: 1.0,
                                                 constant: number)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func tsv_makeConstraint(_ attribute: TSVLayoutConstraintAttribute,
                            equalTo view: UIView,
                            multiplier: CGFloat = 1.0,
                            constant: CGFloat = 0.0) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint.init(item: self,
                                                 attribute: attribute,
                                                 relatedBy: .equal,
                                                 toItem: view,
                                                 attribute: attribute,
                                                 multiplier: multiplier,
                                                 constant: constant)
        
        switch attribute {
        case .width, .height:
            view.addConstraint(constraint)
        default:
            if view != self.superview {
                view.addConstraint(constraint)
            } else {
                self.superview?.addConstraint(constraint)
            }
        }
        return constraint
    }
    
    @discardableResult
    func tsv_makeConstraint(_ attr: TSVLayoutConstraintAttribute,
                            equalTo view: UIView,
                            attribute: TSVLayoutConstraintAttribute,
                            multiplier: CGFloat = 1.0,
                            constant: CGFloat = 0.0) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint.init(item: self,
                                                 attribute: attr,
                                                 relatedBy: .equal,
                                                 toItem: view,
                                                 attribute: attribute,
                                                 multiplier: multiplier,
                                                 constant: constant)
        self.superview?.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func tsv_makeConstraints(_ attributes: [TSVLayoutConstraintAttribute],
                             equalTo view: UIView,
                             multiplier: CGFloat = 1.0,
                             constant: CGFloat = 0.0) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        for attr in attributes {
            let constraint = self.tsv_makeConstraint(attr,
                                                     equalTo: view,
                                                     multiplier: multiplier,
                                                     constant: constant)
            constraints.append(constraint)
        }
        return constraints
    }
}

