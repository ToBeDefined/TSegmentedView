//
//  PASegmentedControl.swift
//  wanjia2B
//
//  Created by 邵伟男 on 2017/7/18.
//  Copyright © 2017年 邵伟男. All rights reserved.
//


import UIKit

public class TSegmentedControlView: UIView {
    public enum SeparateStyle {
        case none
        case top
        case bottom
        case topAndBottom
    }
    
    var currentIndex: Int {
        return _currentIndex
    }
    
    var separateStyle: SeparateStyle = .topAndBottom {
        didSet {
            self.changeSeparateStyle()
        }
    }
    
    var actionBlock: ((_ index: Int) -> ())?
    
    var titles: [String]! {
        didSet {
            self.creatViews(with: titles)
        }
    }
    
    var normalColor = UIColor.black
    var normalFont = UIFont.systemFont(ofSize: 14)
    var selectColor = UIColor.orange
    var selectFont = UIFont.boldSystemFont(ofSize: 15)
    
    fileprivate var _currentIndex: Int = -1 {
        didSet {
            if oldValue == _currentIndex {
                return
            }
            if oldValue >= 0 && oldValue < controls.count  {
                controls[oldValue].isSelected = false
            }
            if _currentIndex >= 0 && _currentIndex < controls.count {
                controls[_currentIndex].isSelected = true
            } else {
                _currentIndex = 0
            }
        }
    }
    
    private var controls = [PAControl]()
    private var topLine: UIImageView!
    private var bottomLine: UIImageView!
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect = CGRect.zero) {
        var frame = frame
        if frame == CGRect.zero {
            frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44)
        }
        super.init(frame: frame)
        
        let color = UIColor.init(withTSVRGBValue: 0xDFDFDF)
        let colorImage = UIImage.init(tsvcolor: color)
        
        topLine = UIImageView()
        topLine.image = colorImage
        self.addSubview(topLine)
        topLine.tsv_makeConstraints([.left, .right, .top], equalTo: self)
        topLine.tsv_makeConstraint(.height, is: 1.0 / UIScreen.main.scale)
        
        bottomLine = UIImageView()
        bottomLine.image = colorImage
        self.addSubview(bottomLine)
        bottomLine.tsv_makeConstraints([.left, .bottom, .right], equalTo: self)
        bottomLine.tsv_makeConstraint(.height, is: 1.0 / UIScreen.main.scale)
    }
    
    private func creatViews(with titles: [String]) {
        for v in controls {
            v.removeFromSuperview()
        }
        controls.removeAll()
        
        let count = CGFloat(titles.count)
        for index in 0..<titles.count {
            let control = PAControl()
            control.addTarget(self, action: #selector(self.clickControl(_:)), for: .touchUpInside)
            control.label.text = titles[index]
            control.normalColor = self.normalColor
            control.normalFont = self.normalFont
            control.selectColor = self.selectColor
            control.selectFont = self.selectFont
            control.applyStyle()
            self.addSubview(control)
            if index == 0 {
                control.tsv_makeConstraint(.left, equalTo: self)
            } else {
                control.tsv_makeConstraint(.left, equalTo: self.controls[index-1], attribute: .right)
            }
            control.tsv_makeConstraints([.top, .bottom], equalTo: self)
            control.tsv_makeConstraint(.width, equalTo: self, multiplier: 1.0/count)
            controls.append(control)
        }
    }
    
    func applyStyle() {
        for control in controls {
            control.normalColor = self.normalColor
            control.normalFont = self.normalFont
            control.selectColor = self.selectColor
            control.selectFont = self.selectFont
            control.applyStyle()
        }
    }
    
    private func changeSeparateStyle() {
        switch self.separateStyle {
        case .top:
            topLine.isHidden = false
            bottomLine.isHidden = true
        case .bottom:
            topLine.isHidden = true
            bottomLine.isHidden = false
        case .topAndBottom:
            topLine.isHidden = false
            bottomLine.isHidden = false
        default:
            topLine.isHidden = true
            bottomLine.isHidden = true
        }
    }
    
    @objc private func clickControl(_ control: PAControl) {
        let index = self.controls.index(of: control) ?? 0
        _currentIndex = index
        self.actionBlock?(index)
    }
}

extension TSegmentedControlView: TSegmentedControlProtocol {
    public func setAction(_ actionBlock: ((Int) -> Void)?) {
        self.actionBlock = actionBlock
    }
    
    public func userScrollExtent(_ extent: CGFloat) {
        let index = Int(extent + 0.5)
        _currentIndex = index
    }
    
    public func reloadData(with titles: [String]) {
        self.titles = titles
    }
}


class PAControl: UIControl {
    
    override var isSelected: Bool {
        didSet {
            self.changeSelected()
        }
    }
    
    var normalColor = UIColor.black
    var normalFont = UIFont.systemFont(ofSize: 14)
    var selectColor = UIColor.orange
    var selectFont = UIFont.boldSystemFont(ofSize: 16)
    
    var label: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.setupViews()
    }
    
    
    func setupViews() {
        label = UILabel()
        self.addSubview(label)
        label.tsv_makeConstraints([.left, .top, .bottom, .right], equalTo: self)
        label.backgroundColor = UIColor.clear
        label.textColor = self.normalColor
        label.font = self.normalFont
        label.textAlignment = .center
    }
    
    func applyStyle() {
        self.changeSelected()
    }
    
    private func changeSelected() {
        if isSelected {
            label.textColor = self.selectColor
            label.font = self.selectFont
        } else {
            label.textColor = self.normalColor
            label.font = self.normalFont
        }
    }
}






