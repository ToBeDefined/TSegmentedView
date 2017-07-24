//
//  PASegmentTableView.swift
//  wanjia2B
//
//  Created by 邵伟男 on 2017/7/18.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit

@objc public protocol TSegmentedControlProtocol: class {
    func reloadData(with titles: [String]) -> Void
    func userScrollExtent(_ extent: CGFloat) -> Void
    func setAction(_ actionBlock: ((_ index: Int) -> Void)?) -> Void
}

@objc public protocol TSegmentedViewDelegate: class {
    
    func segmentedViewTitles(in segmentedView: TSegmentedView) -> [String]
    
    func segmentedView(_ view: TSegmentedView, viewForIndex index: Int) -> UIView
    
    @objc optional func segmentedView(_ view: TSegmentedView, didShow index: Int) -> Void
    
    @objc optional func segmentedViewSegmentedControlView(in segmentedView: TSegmentedView) -> UIView
    // default is 0
    @objc optional func segmentedViewFirstStartSelectIndex(in segmentedView: TSegmentedView) -> Int
    // default is nil
    @objc optional func segmentedViewHeaderView(in segmentedView: TSegmentedView) -> UIView
    // default is segmentedViewHeaderView height
    @objc optional func segmentedViewHeaderMaxHeight(in segmentedView: TSegmentedView) -> CGFloat
    // default is segmentedViewHeaderView height
    @objc optional func segmentedViewHeaderMinHeight(in segmentedView: TSegmentedView) -> CGFloat
    // when scroll top or bottom, change the titles view height , will run this method
    @objc optional func segmentedView(_ view: TSegmentedView, didChangeHeaderHeightTo height: CGFloat) -> Void
    
}

public class TSegmentedView: UIView {
    weak var delegate: TSegmentedViewDelegate?
    
    var currentIndex: Int {
        get {
            return _currentIndex
        }
    }
    
    // Height
    fileprivate var headerMaxHeight: CGFloat = 300
    fileprivate var headerMinHeight: CGFloat = 100
    fileprivate var currentHeaderHeight: CGFloat = 300 {
        didSet {
            self.updateHeaderViewConstraints()
        }
    }
    
    // page current/count
    fileprivate var _currentIndex: Int = -1
    
    fileprivate var pageCount: Int = 0
    
    // views
    fileprivate var scrollView: UIScrollView!
    fileprivate var backgroundView: UIView!
    fileprivate var headerView: UIView!
    fileprivate var viewArray = [UIScrollView]()
    // segmentedControlView 的类型在swift3中无法设置为 UIView & TSegmentedControlProtocol
    // swift4 中改变为 UIView & TSegmentedControlProtocol 类型
    fileprivate var segmentedControlView: UIView?
    fileprivate var segmentedControlView_P: TSegmentedControlProtocol? {
        get {
            if segmentedControlView != nil {
                assert((segmentedControlView as? TSegmentedControlProtocol) != nil, "segmentedControl must is 'nil' or a 'UIView and conforming to TSegmentedControlProtocol'")
            }
            return segmentedControlView as? TSegmentedControlProtocol
        }
    }
    
    // signal 
    fileprivate var isUserScroll: Bool = false
    fileprivate var isFirstLayout: Bool = true
    fileprivate var isFirstReloadData: Bool = true
    fileprivate var headerViewHeightConstraint: NSLayoutConstraint?
    
    deinit {
        self.removeObserver(from: viewArray[_currentIndex])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.clear
        self.addSubview(backgroundView)
        backgroundView.tsv_makeConstraints([.left, .right, .top, .bottom], equalTo: self)
        
        scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor.clear
        scrollView.isScrollEnabled = true
        scrollView.bounces = false
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        self.addSubview(scrollView)
        scrollView.tsv_makeConstraints([.left, .right, .top, .bottom], equalTo: self)
    }
    
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if isFirstLayout {
            isFirstLayout = false
            self.selectDefaultIndex()
        }
    }
    
    func reloadData() {
        guard let delegate = self.delegate else {
            return
        }
        
        if !self.isFirstReloadData {
            // 不是第一次reloadData的时候需要移除之前的Observe
            self.removeObserver(from: self.viewArray[_currentIndex])
        }
        
        // 清理之前存在的view
        for v in self.viewArray {
            v.removeFromSuperview()
        }
        self.viewArray.removeAll()
        
        let titles = delegate.segmentedViewTitles(in: self)
        pageCount = titles.count
        
        let headerView = delegate.segmentedViewHeaderView?(in: self)
        self.createHeader(baseHeader: headerView, titles: titles)
        
        
        for index in 0..<pageCount {
            let view = delegate.segmentedView(self, viewForIndex: index)
            self.addView(view, to: index)
        }
        
        // 不是第一次reloadData时候直接去选择index
        if !self.isFirstReloadData {
            self.selectDefaultIndex()
        }
        self.isFirstReloadData = false
    }
    
    
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if /*self.scrollView.contentOffset.x <= 0 &&*/ point.x <= 20 {
            return self.backgroundView.hitTest(point, with: event)
        }
        return super.hitTest(point, with: event)
    }
    
    fileprivate func updateHeaderViewConstraints() {
        if self.headerView == nil {
            return
        }
        
        headerViewHeightConstraint?.constant = self.currentHeaderHeight
        self.delegate?.segmentedView?(self, didChangeHeaderHeightTo: self.currentHeaderHeight)
        // 如果下滑，并将头部下拉了则重设每个scrollview的contentOffset
        if currentHeaderHeight > headerMinHeight {
            for v in self.viewArray {
                if v != self.viewArray[_currentIndex] {
                    if v is UITableView {
                        // tableView需要去掉（headerMaxHeight - headerMinHeight）的header额外增加的高度
                        v.contentOffset.y = -currentHeaderHeight + (headerMaxHeight - headerMinHeight)
                    } else {
                        v.contentOffset.y = -currentHeaderHeight
                    }
                }
            }
        }
    }
    
    fileprivate func selectDefaultIndex() {
        var index = self.delegate?.segmentedViewFirstStartSelectIndex?(in: self) ?? 0
        if index < 0 || index >= pageCount {
            index = 0
        }
        _currentIndex = index
        self.scrollView(scrollTo: index, animated: false)
        self.segmentedControlView_P?.userScrollExtent(self.scrollView.contentOffset.x/self.frame.width)
        self.addObserver(to: viewArray[index])
    }
}

// MARK: Create Layout Views
extension TSegmentedView {
    // 创建header
    fileprivate func createHeader(baseHeader: UIView?, titles: [String]) {
        let minHeight = delegate?.segmentedViewHeaderMinHeight?(in: self)
        let maxHeight = delegate?.segmentedViewHeaderMaxHeight?(in: self)
        let baseHeaderHeight:CGFloat = baseHeader?.frame.height ?? 0
        
        segmentedControlView = delegate?.segmentedViewSegmentedControlView?(in: self)
        let segmentedHeight: CGFloat = segmentedControlView?.frame.height ?? 0.0
        
        headerMinHeight = (minHeight ?? baseHeaderHeight) + segmentedHeight
        headerMaxHeight = (maxHeight ?? baseHeaderHeight) + segmentedHeight
        currentHeaderHeight = headerMaxHeight
        if headerView == nil {
            headerView = UIView()
            headerView.backgroundColor = UIColor.white
            self.addSubview(headerView)
        } else {
            // 清理headerview的subviews
            for v in self.headerView.subviews {
                v.removeFromSuperview()
            }
        }
        
        headerView.removeConstraints(headerView.constraints)
        headerView.tsv_makeConstraints([.left, .top, .right], equalTo: self)
        headerViewHeightConstraint = headerView.tsv_makeConstraint(.height, is: self.headerMaxHeight)
        
        if let baseHeader = baseHeader  {
            headerView.addSubview(baseHeader)
            baseHeader.tsv_makeConstraints([.left, .top, .right], equalTo: self.headerView)
            baseHeader.tsv_makeConstraint(.bottom, equalTo: self.headerView, multiplier: 1.0, constant: -segmentedHeight)
        }
        
        if segmentedControlView != nil {
            headerView.addSubview(segmentedControlView!)
            segmentedControlView!.tsv_makeConstraints([.left, .right, .bottom], equalTo: self.headerView)
            segmentedControlView!.tsv_makeConstraint(.height, is: segmentedHeight)
        }
        
        segmentedControlView_P?.setAction({ [weak self] (index) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.isUserScroll = false
            strongSelf.removeObserver(from: strongSelf.viewArray[strongSelf._currentIndex])
            strongSelf.addObserver(to: strongSelf.viewArray[index])
            strongSelf._currentIndex = index
            strongSelf.scrollView(scrollTo: index, animated: true)
        })
        segmentedControlView_P?.reloadData(with: titles)
    }
    
    // 添加view到self.scrollView上
    fileprivate func addView(_ view: UIView, to index: Int) {
        switch view {
        case let tableView as UITableView:
            self.disposeTableView(tableView, to: index)
        case let subScrollView as UIScrollView:
            self.disposeScrollView(subScrollView, to: index)
        default:
            self.disposeCommonView(view, to: index)
        }
    }
    
    // 处理普通view，外层套一个scrollview
    fileprivate func disposeCommonView(_ view: UIView, to index: Int) {
        let subScrollView = UIScrollView()
        subScrollView.backgroundColor = UIColor.clear
        self.disposeScrollView(subScrollView, to: index)
        
        let viewHeight = view.frame.height
        subScrollView.addSubview(view)
        view.tsv_makeConstraints([.left, .right, .top, .bottom], equalTo: subScrollView)
        view.tsv_makeConstraint(.width, equalTo: self)
        if viewHeight != 0 {
            view.tsv_makeConstraint(.height, is: viewHeight)
        } else {
            view.tsv_makeConstraint(.height, equalTo: self)
        }
    }
    
    // 处理scrollview
    fileprivate func disposeScrollView(_ subScrollView: UIScrollView, to index: Int) {
        subScrollView.contentInset = UIEdgeInsets.init(top: headerMaxHeight, left: 0, bottom: 0, right: 0)
        subScrollView.scrollIndicatorInsets = UIEdgeInsets.init(top: headerMaxHeight, left: 0, bottom: 0, right: 0)
        subScrollView.contentOffset = CGPoint.init(x: 0, y: -headerMaxHeight)
        subScrollView.isScrollEnabled = true
        self.layoutView(subScrollView, to: index)
    }
    
    // 处理tableView
    fileprivate func disposeTableView(_ tableView: UITableView, to index: Int) {
        // 处理tableView的content等等
        tableView.contentInset = UIEdgeInsets.init(top: headerMinHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint.init(x: 0, y: -headerMinHeight)
        tableView.scrollIndicatorInsets = UIEdgeInsets.init(top: headerMaxHeight, left: 0, bottom: 0, right: 0)
        
        // 处理tableView.tableHeaderView
        if let view = tableView.tableHeaderView {
            tableView.tableHeaderView = nil
            let viewWidth = UIScreen.main.bounds.width
            let viewHeight = view.frame.height
            view.frame.size.width = viewWidth
            let tableHeaderView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: viewWidth, height: viewHeight + headerMaxHeight - headerMinHeight))
            tableHeaderView.backgroundColor = UIColor.clear
            tableHeaderView.addSubview(view)
            view.tsv_makeConstraints([.left, .right, .bottom], equalTo: tableHeaderView)
            view.tsv_makeConstraint(.height, is: viewHeight)
            tableView.tableHeaderView = tableHeaderView
        } else {
            let tableHeaderView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.headerMaxHeight - self.headerMinHeight))
            tableHeaderView.backgroundColor = UIColor.clear
            tableView.tableHeaderView = tableHeaderView
        }
        self.layoutView(tableView, to: index)
    }
    
    fileprivate func layoutView(_ view: UIScrollView, to index: Int) {
        self.scrollView.addSubview(view)
        self.viewArray.append(view)
        
        view.tsv_makeConstraints([.top, .bottom], equalTo: self.scrollView)
        view.tsv_makeConstraints([.height, .width], equalTo: self)
        if index == 0 {
            view.tsv_makeConstraint(.left, equalTo: self.scrollView)
        } else {
            view.tsv_makeConstraint(.left, equalTo: self.viewArray[index-1], attribute: .right)
        }
        
        if index == self.pageCount - 1 {
            view.tsv_makeConstraint(.right, equalTo: self.scrollView)
        }
    }
}

// MARK: Observe
extension TSegmentedView {
    fileprivate func addObserver(to scrollView: UIScrollView) {
        scrollView.addObserver(self,
                               forKeyPath: "contentOffset",
                               options: [NSKeyValueObservingOptions.old, NSKeyValueObservingOptions.new],
                               context: nil)
    }
    
    fileprivate func removeObserver(from scrollView: UIScrollView) {
        scrollView.removeObserver(self, forKeyPath: "contentOffset", context: nil)
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        func changeOffsetY(dlt: CGFloat) {
            if let scrollView = object as? UIScrollView {
                for v in self.viewArray {
                    if v != scrollView {
                        v.contentOffset.y += dlt
                    }
                }
            }
        }
        if let sv = object as? UIScrollView, keyPath == "contentOffset" {
            let realOffsetY = sv.contentOffset.y + sv.contentInset.top
            let tempHeight = headerMaxHeight - realOffsetY
            if tempHeight < headerMinHeight {
                changeOffsetY(dlt: currentHeaderHeight - headerMinHeight)
                currentHeaderHeight = headerMinHeight
            } else {
                changeOffsetY(dlt: currentHeaderHeight - tempHeight)
                currentHeaderHeight = tempHeight
            }
        }
    }
}

// MARK: ScrollDelegate & ScrollToIndex
extension TSegmentedView: UIScrollViewDelegate {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.isUserScroll = true
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            if !self.isUserScroll {
                return
            }
            let index = Int((self.frame.width * 0.5 + scrollView.contentOffset.x) / self.frame.width)
            if index == _currentIndex {
                return
            }
            self.removeObserver(from: self.viewArray[_currentIndex])
            self.addObserver(to: self.viewArray[index])
            _currentIndex = index
            self.delegate?.segmentedView?(self, didShow: index)
            self.segmentedControlView_P?.userScrollExtent(scrollView.contentOffset.x/self.frame.width)
        }
    }
    
    public func scrollView(scrollTo index: Int, animated: Bool = true) {
        var width = self.frame.width
        if width == 0 {
            width = UIScreen.main.bounds.width
        }
        let x = width * CGFloat(index)
        let contentOffset = CGPoint.init(x: x, y: 0)
        self.scrollView.setContentOffset(contentOffset, animated: animated)
        self.delegate?.segmentedView?(self, didShow: index)
    }
}





